import hashlib
import uuid
from datetime import timedelta
from django.utils import timezone
from django.db import models
from django.core.exceptions import ValidationError, PermissionDenied
from django.contrib.auth import get_user_model

from apps.campaigns.models import (
    Campaign,
    CampaignStatus,
    CampaignMedia,
    MediaStatus,
    MediaType,
    CampaignAdPlacement,
    PlacementStatus,
)
from apps.campaigns.permissions import is_advertiser_capable
from apps.campaigns.tracking.models import (
    ClickType,
    AdvertisementImpression,
    AdvertisementClick,
    AdvertisementVideoEngagement,
)

User = get_user_model()


class AdvertisementTrackingService:
    """
    Authoritative server-side service for recording advertisement impressions,
    user click interactions, video playback progress, and generating performance analytics.
    """

    @staticmethod
    def record_impression(
        campaign_id,
        placement_id,
        media_id,
        user=None,
        session_id="",
        device_id=None,
        ip_address="",
        user_agent="",
    ) -> AdvertisementImpression:
        """
        Validates and records a single ad impression event.
        Enforces campaign status, placement status, media readiness, and duplicate throttling.
        """
        try:
            campaign = Campaign.objects.get(id=campaign_id)
        except (Campaign.DoesNotExist, ValueError):
            raise ValidationError("Invalid or non-existent campaign.")

        if campaign.status != CampaignStatus.ACTIVE:
            raise ValidationError("Impressions can only be recorded for active campaigns.")

        try:
            placement = CampaignAdPlacement.objects.get(id=placement_id)
        except (CampaignAdPlacement.DoesNotExist, ValueError):
            raise ValidationError("Invalid or non-existent advertisement placement.")

        if placement.status != PlacementStatus.ACTIVE:
            raise ValidationError("Impressions can only be recorded for active placements.")

        if str(placement.campaign_id) != str(campaign.id):
            raise ValidationError("Placement does not belong to the specified campaign.")

        try:
            media = CampaignMedia.objects.get(id=media_id)
        except (CampaignMedia.DoesNotExist, ValueError):
            raise ValidationError("Invalid or non-existent media asset.")

        if media.status != MediaStatus.READY:
            raise ValidationError("Media asset is not ready for display.")

        if str(media.campaign_id) != str(campaign.id) or str(placement.media_id) != str(media.id):
            raise ValidationError("Media asset does not match the campaign or placement.")

        # Throttling / Duplicate Prevention:
        # Check if an identical impression was recorded in the last 5 seconds
        recent_threshold = timezone.now() - timedelta(seconds=5)
        duplicate_query = AdvertisementImpression.objects.filter(
            placement=placement,
            media=media,
            created_at__gte=recent_threshold,
        )

        if user and user.is_authenticated:
            duplicate_query = duplicate_query.filter(user=user)
        elif session_id:
            duplicate_query = duplicate_query.filter(session_id=session_id)

        existing = duplicate_query.first()
        if existing:
            return existing

        # IP Hashing for privacy & fraud detection
        ip_hash = ""
        if ip_address:
            ip_hash = hashlib.sha256(ip_address.encode("utf-8")).hexdigest()

        return AdvertisementImpression.objects.create(
            campaign=campaign,
            placement=placement,
            media=media,
            user=user if (user and user.is_authenticated) else None,
            session_id=session_id or str(uuid.uuid4()),
            device_id=device_id,
            ip_hash=ip_hash,
            user_agent=user_agent[:500] if user_agent else "",
        )

    @staticmethod
    def record_click(
        campaign_id,
        media_id,
        impression_id=None,
        user=None,
        click_type=ClickType.BANNER_CLICK,
        session_id="",
    ) -> AdvertisementClick:
        """
        Validates and records an advertisement interaction click event.
        """
        try:
            campaign = Campaign.objects.get(id=campaign_id)
        except (Campaign.DoesNotExist, ValueError):
            raise ValidationError("Invalid or non-existent campaign.")

        if campaign.status != CampaignStatus.ACTIVE:
            raise ValidationError("Clicks can only be recorded for active campaigns.")

        try:
            media = CampaignMedia.objects.get(id=media_id)
        except (CampaignMedia.DoesNotExist, ValueError):
            raise ValidationError("Invalid or non-existent media asset.")

        if media.status != MediaStatus.READY:
            raise ValidationError("Media asset is not ready.")

        if str(media.campaign_id) != str(campaign.id):
            raise ValidationError("Media asset does not belong to the specified campaign.")

        impression = None
        if impression_id:
            try:
                impression = AdvertisementImpression.objects.get(id=impression_id)
                if str(impression.campaign_id) != str(campaign.id) or str(impression.media_id) != str(media.id):
                    raise ValidationError("Impression does not match campaign or media.")
            except (AdvertisementImpression.DoesNotExist, ValueError):
                raise ValidationError("Referenced impression does not exist.")

        if click_type not in ClickType.values:
            raise ValidationError(f"Invalid click type: {click_type}")

        # Throttling / Rapid click suppression: 2 seconds
        recent_threshold = timezone.now() - timedelta(seconds=2)
        duplicate_click = AdvertisementClick.objects.filter(
            campaign=campaign,
            media=media,
            click_type=click_type,
            created_at__gte=recent_threshold,
        )

        if impression:
            duplicate_click = duplicate_click.filter(impression=impression)
        elif user and user.is_authenticated:
            duplicate_click = duplicate_click.filter(user=user)
        elif session_id:
            duplicate_click = duplicate_click.filter(session_id=session_id)

        existing_click = duplicate_click.first()
        if existing_click:
            return existing_click

        return AdvertisementClick.objects.create(
            impression=impression,
            campaign=campaign,
            media=media,
            user=user if (user and user.is_authenticated) else None,
            click_type=click_type,
            session_id=session_id,
        )

    @staticmethod
    def record_video_progress(
        campaign_id,
        media_id,
        session_id,
        watched_seconds,
        user=None,
    ) -> AdvertisementVideoEngagement:
        """
        Records video ad playback progress.
        Server-side calculation of completion percentage and completed flag.
        """
        if not session_id:
            raise ValidationError("Session ID is required for video engagement tracking.")

        try:
            campaign = Campaign.objects.get(id=campaign_id)
        except (Campaign.DoesNotExist, ValueError):
            raise ValidationError("Invalid or non-existent campaign.")

        if campaign.status != CampaignStatus.ACTIVE:
            raise ValidationError("Engagement can only be tracked for active campaigns.")

        try:
            media = CampaignMedia.objects.get(id=media_id)
        except (CampaignMedia.DoesNotExist, ValueError):
            raise ValidationError("Invalid or non-existent media asset.")

        if media.status != MediaStatus.READY:
            raise ValidationError("Media asset is not ready.")

        if str(media.campaign_id) != str(campaign.id):
            raise ValidationError("Media asset does not belong to the specified campaign.")

        if media.media_type != MediaType.VIDEO:
            raise ValidationError("Video progress tracking is only applicable to video creatives.")

        try:
            watched_seconds_float = max(0.0, float(watched_seconds))
        except (ValueError, TypeError):
            raise ValidationError("Watched seconds must be a valid non-negative number.")

        # Fetch or create engagement session
        engagement, created = AdvertisementVideoEngagement.objects.get_or_create(
            campaign=campaign,
            media=media,
            session_id=session_id,
            defaults={
                "user": user if (user and user.is_authenticated) else None,
                "watched_seconds": watched_seconds_float,
            },
        )

        if not created:
            # Monotonic progress update: watched seconds cannot decrease
            watched_seconds_float = max(engagement.watched_seconds, watched_seconds_float)
            engagement.watched_seconds = watched_seconds_float
            if user and user.is_authenticated and not engagement.user:
                engagement.user = user

        # Authoritative Server-side completion calculation
        duration = float(media.duration_seconds or 0)
        if duration > 0:
            percentage = min(100.0, (watched_seconds_float / duration) * 100.0)
            engagement.completion_percentage = round(percentage, 2)
            if percentage >= 95.0 or watched_seconds_float >= duration:
                engagement.completed = True
        else:
            engagement.completion_percentage = 100.0 if watched_seconds_float > 0 else 0.0
            if watched_seconds_float > 0:
                engagement.completed = True

        engagement.save()
        return engagement

    @staticmethod
    def generate_campaign_statistics(campaign_id, user=None) -> dict:
        """
        Generates comprehensive statistics and analytics for a single campaign.
        Enforces tenant isolation (advertisers see only their campaigns; admins see all).
        """
        try:
            campaign = Campaign.objects.get(id=campaign_id)
        except (Campaign.DoesNotExist, ValueError):
            raise ValidationError("Campaign not found.")

        if user and not (user.is_staff or user.is_superuser):
            if not is_advertiser_capable(user) or str(campaign.owner_id) != str(user.id):
                raise PermissionDenied("You do not have permission to view analytics for this campaign.")

        # 1. Impressions & Unique Viewers
        impressions_qs = AdvertisementImpression.objects.filter(campaign=campaign)
        total_impressions = impressions_qs.count()
        unique_sessions = impressions_qs.values("session_id").distinct().count()

        # 2. Clicks & CTR
        clicks_qs = AdvertisementClick.objects.filter(campaign=campaign)
        total_clicks = clicks_qs.count()
        ctr = round((total_clicks / total_impressions * 100.0), 2) if total_impressions > 0 else 0.0

        # Clicks Breakdown by type
        clicks_by_type = {}
        for ctype in ClickType.values:
            clicks_by_type[ctype] = clicks_qs.filter(click_type=ctype).count()

        # 3. Video Engagement
        video_engagements_qs = AdvertisementVideoEngagement.objects.filter(campaign=campaign)
        total_video_plays = video_engagements_qs.count()
        completed_videos = video_engagements_qs.filter(completed=True).count()
        video_completion_rate = (
            round((completed_videos / total_video_plays * 100.0), 2)
            if total_video_plays > 0
            else 0.0
        )
        avg_watch_duration = (
            round(
                video_engagements_qs.aggregate(avg=models.Avg("watched_seconds"))["avg"] or 0.0,
                1,
            )
        )

        # 4. Creative Performance Breakdown
        creatives_performance = []
        medias = CampaignMedia.objects.filter(campaign=campaign)
        for m in medias:
            m_imps = AdvertisementImpression.objects.filter(media=m).count()
            m_clicks = AdvertisementClick.objects.filter(media=m).count()
            m_ctr = round((m_clicks / m_imps * 100.0), 2) if m_imps > 0 else 0.0

            m_data = {
                "media_id": str(m.id),
                "title": m.title,
                "media_type": m.media_type,
                "media_type_display": m.get_media_type_display(),
                "file_url": m.file.url if m.file else "",
                "status": m.status,
                "impressions": m_imps,
                "clicks": m_clicks,
                "ctr": m_ctr,
            }

            if m.media_type == MediaType.VIDEO:
                v_plays = AdvertisementVideoEngagement.objects.filter(media=m).count()
                v_completes = AdvertisementVideoEngagement.objects.filter(media=m, completed=True).count()
                v_rate = round((v_completes / v_plays * 100.0), 2) if v_plays > 0 else 0.0
                v_avg_sec = round(
                    AdvertisementVideoEngagement.objects.filter(media=m).aggregate(avg=models.Avg("watched_seconds"))["avg"] or 0.0,
                    1,
                )
                m_data.update({
                    "video_plays": v_plays,
                    "video_completions": v_completes,
                    "completion_rate": v_rate,
                    "avg_watch_duration": v_avg_sec,
                })
            creatives_performance.append(m_data)

        # 5. Timeline Activity (Last 14 days)
        now = timezone.now()
        start_date = now - timedelta(days=14)
        timeline = []
        for day_offset in range(14):
            day_start = (start_date + timedelta(days=day_offset)).replace(hour=0, minute=0, second=0, microsecond=0)
            day_end = day_start + timedelta(days=1)
            day_imps = impressions_qs.filter(created_at__gte=day_start, created_at__lt=day_end).count()
            day_clks = clicks_qs.filter(created_at__gte=day_start, created_at__lt=day_end).count()
            timeline.append({
                "date": day_start.strftime("%Y-%m-%d"),
                "impressions": day_imps,
                "clicks": day_clks,
            })

        return {
            "campaign_id": str(campaign.id),
            "campaign_title": campaign.title,
            "campaign_type": campaign.campaign_type,
            "campaign_status": campaign.status,
            "total_impressions": total_impressions,
            "unique_viewers": unique_sessions,
            "total_clicks": total_clicks,
            "click_through_rate": ctr,
            "clicks_by_type": clicks_by_type,
            "video_metrics": {
                "total_plays": total_video_plays,
                "completions": completed_videos,
                "completion_rate": video_completion_rate,
                "average_watch_duration": avg_watch_duration,
            },
            "creatives_performance": creatives_performance,
            "timeline": timeline,
        }

    @staticmethod
    def generate_advertiser_overview(user) -> dict:
        """
        Generates overall analytics dashboard statistics for an advertiser
        or platform-wide statistics for staff/admins.
        """
        if not user or not user.is_authenticated:
            raise PermissionDenied("Authentication required to view analytics.")

        if user.is_staff or user.is_superuser:
            campaigns = Campaign.objects.all()
        else:
            if not is_advertiser_capable(user):
                raise PermissionDenied("Advertiser capability required to view analytics.")
            campaigns = Campaign.objects.filter(owner=user)

        total_campaigns = campaigns.count()
        active_campaigns = campaigns.filter(status=CampaignStatus.ACTIVE).count()

        impressions_qs = AdvertisementImpression.objects.filter(campaign__in=campaigns)
        clicks_qs = AdvertisementClick.objects.filter(campaign__in=campaigns)
        video_qs = AdvertisementVideoEngagement.objects.filter(campaign__in=campaigns)

        total_impressions = impressions_qs.count()
        unique_viewers = impressions_qs.values("session_id").distinct().count()
        total_clicks = clicks_qs.count()
        overall_ctr = round((total_clicks / total_impressions * 100.0), 2) if total_impressions > 0 else 0.0

        total_video_plays = video_qs.count()
        video_completions = video_qs.filter(completed=True).count()
        video_completion_rate = (
            round((video_completions / total_video_plays * 100.0), 2)
            if total_video_plays > 0
            else 0.0
        )
        avg_watch_duration = round(video_qs.aggregate(avg=models.Avg("watched_seconds"))["avg"] or 0.0, 1)

        # Top performing campaigns by impressions and CTR
        campaign_summaries = []
        for c in campaigns[:10]:
            c_imps = AdvertisementImpression.objects.filter(campaign=c).count()
            c_clks = AdvertisementClick.objects.filter(campaign=c).count()
            c_ctr = round((c_clks / c_imps * 100.0), 2) if c_imps > 0 else 0.0
            campaign_summaries.append({
                "id": str(c.id),
                "title": c.title,
                "status": c.status,
                "impressions": c_imps,
                "clicks": c_clks,
                "ctr": c_ctr,
            })

        # Sort by impressions descending
        campaign_summaries.sort(key=lambda x: x["impressions"], reverse=True)

        return {
            "total_campaigns": total_campaigns,
            "active_campaigns": active_campaigns,
            "total_impressions": total_impressions,
            "unique_viewers": unique_viewers,
            "total_clicks": total_clicks,
            "overall_ctr": overall_ctr,
            "video_metrics": {
                "total_plays": total_video_plays,
                "completions": video_completions,
                "completion_rate": video_completion_rate,
                "average_watch_duration": avg_watch_duration,
            },
            "top_campaigns": campaign_summaries[:5],
        }
