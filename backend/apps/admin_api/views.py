import logging
from decimal import Decimal
from datetime import timedelta
from django.utils import timezone
from django.db.models import Sum, Count, Q, F
from django.contrib.auth import get_user_model
from rest_framework import viewsets, status, permissions, generics
from rest_framework.views import APIView
from rest_framework.decorators import action
from rest_framework.response import Response

from apps.tasks.models import Task, TaskStatus, TaskAttempt, TaskRewardGrant
from apps.tasks.services import extract_youtube_metadata
from apps.tracking.models import WatchSession, WatchSessionStatus, WatchEvent
from apps.wallet.models import Wallet, CoinTransaction, CashTransaction, CoinTransactionType, CashTransactionType
from apps.wallet.services import WalletService
from apps.ai.models import AIProviderConfig
from apps.ai.services import fetch_openrouter_models_list
from .permissions import IsAdminOrStaff
from .serializers import (
    AdminUserSerializer,
    AdminUserBalanceAdjustmentSerializer,
    AdminVideoTaskSerializer,
    AdminWatchSessionSerializer,
    AdminCoinTransactionSerializer,
    AdminAIProviderConfigSerializer,
    AdminTestPromptSerializer,
)

User = get_user_model()
logger = logging.getLogger(__name__)


def get_chart_intervals(range_key):
    now = timezone.now()
    intervals = []

    if range_key == '1h':
        for i in range(6):
            start = now - timedelta(minutes=(6 - i) * 10)
            end = now - timedelta(minutes=(5 - i) * 10)
            intervals.append((start, end, start.strftime('%H:%M')))
    elif range_key in ['1d', '24h']:
        for i in range(12):
            start = now - timedelta(hours=(12 - i) * 2)
            end = now - timedelta(hours=(11 - i) * 2)
            intervals.append((start, end, start.strftime('%H:%M')))
    elif range_key in ['30d', '1m']:
        for i in range(10):
            start = now - timedelta(days=(10 - i) * 3)
            end = now - timedelta(days=(9 - i) * 3)
            intervals.append((start, end, start.strftime('%b %d')))
    elif range_key in ['6m', '1y', '12m']:
        for i in range(6):
            start = now - timedelta(days=(6 - i) * 30)
            end = now - timedelta(days=(5 - i) * 30)
            intervals.append((start, end, start.strftime('%b %Y')))
    else:  # default '7d'
        today_start = now.replace(hour=0, minute=0, second=0, microsecond=0)
        seven_days_ago = today_start - timedelta(days=6)
        for i in range(7):
            start = seven_days_ago + timedelta(days=i)
            end = start + timedelta(days=1)
            intervals.append((start, end, start.strftime('%b %d')))

    return intervals


class DashboardStatsView(APIView):
    """
    Executive KPIs and time-series chart data for Recharts visualization.
    """
    permission_classes = [IsAdminOrStaff]

    def get(self, request):
        now = timezone.now()
        today_start = now.replace(hour=0, minute=0, second=0, microsecond=0)
        range_key = request.query_params.get('range', '7d').lower()

        # 1. Executive KPIs
        total_users = User.objects.count()
        total_active_users = User.objects.filter(is_active=True).count()
        active_tasks = Task.objects.filter(status=TaskStatus.ACTIVE).count()
        total_tasks = Task.objects.count()

        total_watch_seconds = WatchSession.objects.aggregate(
            total=Sum('credited_watch_seconds')
        )['total'] or 0
        total_watch_minutes = round(total_watch_seconds / 60, 1)

        total_coins_paid = CoinTransaction.objects.filter(
            transaction_type=CoinTransactionType.REWARD
        ).aggregate(total=Sum('amount'))['total'] or 0

        # Active real-time sessions in the last 45 seconds (heartbeat cadence is 15s)
        active_sessions_threshold = now - timedelta(seconds=45)
        live_sessions = WatchSession.objects.filter(
            status=WatchSessionStatus.ACTIVE,
            last_heartbeat_at__gte=active_sessions_threshold
        ).count()

        tasks_completed_today = TaskAttempt.objects.filter(
            reward_granted=True,
            completed_at__gte=today_start
        ).count()

        # 2. Time-series intervals for charts
        intervals = get_chart_intervals(range_key)
        chart_data = []

        for start, end, label in intervals:
            watch_sec = WatchSession.objects.filter(
                started_at__gte=start,
                started_at__lt=end
            ).aggregate(total=Sum('credited_watch_seconds'))['total'] or 0

            new_users = User.objects.filter(
                created_at__gte=start,
                created_at__lt=end
            ).count()

            coins = CoinTransaction.objects.filter(
                transaction_type=CoinTransactionType.REWARD,
                created_at__gte=start,
                created_at__lt=end
            ).aggregate(total=Sum('amount'))['total'] or 0

            completions = TaskAttempt.objects.filter(
                reward_granted=True,
                completed_at__gte=start,
                completed_at__lt=end
            ).count()

            chart_data.append({
                'date': label,
                'label': label,
                'watch_seconds': watch_sec,
                'watch_minutes': round(watch_sec / 60, 1),
                'coins_distributed': coins,
                'coins_paid': coins,
                'new_users': new_users,
                'completions': completions,
            })

        # 3. Recent Realtime Watch Activity
        recent_sessions = WatchSession.objects.select_related('user', 'task', 'attempt').order_by('-started_at')[:10]
        recent_activity = []
        for s in recent_sessions:
            is_live = bool(s.status == WatchSessionStatus.ACTIVE and s.last_heartbeat_at and s.last_heartbeat_at >= active_sessions_threshold)
            is_completed = bool(s.status == WatchSessionStatus.COMPLETED or (s.attempt and s.attempt.reward_granted))
            last_time = s.last_heartbeat_at or s.started_at or now
            recent_activity.append({
                'id': str(s.id),
                'user': s.user.email if s.user else 'Anonymous',
                'username': s.user.username if s.user and s.user.username else (s.user.email if s.user else 'User'),
                'email': s.user.email if s.user else '',
                'user_email': s.user.email if s.user else '',
                'user_username': s.user.username if s.user else '',
                'task_title': s.task.title if s.task else 'Video Task',
                'task_id': str(s.task.id) if s.task else '',
                'watched_seconds': s.credited_watch_seconds,
                'credited_watch_seconds': s.credited_watch_seconds,
                'status': s.status,
                'is_live': is_live,
                'is_completed': is_completed,
                'started_at': s.started_at.isoformat() if s.started_at else None,
                'last_heartbeat_at': s.last_heartbeat_at.isoformat() if s.last_heartbeat_at else None,
                'updated_at': last_time.isoformat(),
            })

        return Response({
            'status': 'success',
            'kpis': {
                'total_users': total_users,
                'total_active_users': total_active_users,
                'active_tasks_count': active_tasks,
                'active_tasks': active_tasks,
                'total_tasks': total_tasks,
                'total_watch_seconds_all_videos': total_watch_seconds,
                'total_watch_minutes': total_watch_minutes,
                'total_coins_distributed': total_coins_paid,
                'total_coins_paid': total_coins_paid,
                'active_watch_sessions_count': live_sessions,
                'live_sessions': live_sessions,
                'tasks_completed_today': tasks_completed_today,
            },
            'trends': chart_data,
            'daily_trends': chart_data,
            'recent_activity': recent_activity,
        })


class AdminTaskViewSet(viewsets.ModelViewSet):
    """
    CRUD and AI metadata generation for YouTube Video Tasks.
    """
    queryset = Task.objects.all().order_by('-created_at')
    serializer_class = AdminVideoTaskSerializer
    permission_classes = [IsAdminOrStaff]

    @action(detail=True, methods=['post'], url_path='regenerate-keywords')
    def regenerate_keywords(self, request, pk=None):
        task = self.get_object()
        try:
            meta = extract_youtube_metadata(task.source_url or task.video_id)
            task.keywords = meta.get('keywords', task.keywords)
            if meta.get('keywords'):
                task.search_keywords = meta['keywords'][0]
            task.save()
            return Response({
                'status': 'success',
                'message': f"Successfully generated {len(task.keywords)} OpenRouter keywords.",
                'keywords': task.keywords,
            })
        except Exception as e:
            logger.error("Error generating keywords for task %s: %s", task.id, e)
            return Response({
                'status': 'error',
                'message': str(e),
            }, status=status.HTTP_400_BAD_REQUEST)

    @action(detail=False, methods=['post'], url_path='fetch-youtube-meta')
    def fetch_youtube_meta(self, request):
        url = request.data.get('youtube_url', '').strip()
        if not url:
            return Response({
                'status': 'error',
                'message': 'youtube_url is required',
            }, status=status.HTTP_400_BAD_REQUEST)

        try:
            meta = extract_youtube_metadata(url)
            return Response({
                'status': 'success',
                'data': meta,
            })
        except Exception as e:
            return Response({
                'status': 'error',
                'message': str(e),
            }, status=status.HTTP_400_BAD_REQUEST)


class AdminWatchSessionViewSet(viewsets.ReadOnlyModelViewSet):
    """
    Telemetry and session history inspector for fraud analysis.
    """
    queryset = WatchSession.objects.select_related('user', 'task').order_by('-started_at')
    serializer_class = AdminWatchSessionSerializer
    permission_classes = [IsAdminOrStaff]

    def get_queryset(self):
        qs = super().get_queryset()
        status_filter = self.request.query_params.get('status')
        task_id = self.request.query_params.get('task_id')
        user_id = self.request.query_params.get('user_id')

        if status_filter:
            qs = qs.filter(status=status_filter.upper())
        if task_id:
            qs = qs.filter(task_id=task_id)
        if user_id:
            qs = qs.filter(user_id=user_id)
        return qs

    @action(detail=False, methods=['get'], url_path='live')
    def live(self, request):
        threshold = timezone.now() - timedelta(seconds=45)
        live_sessions = self.get_queryset().filter(
            status=WatchSessionStatus.ACTIVE,
            last_heartbeat_at__gte=threshold
        )
        serializer = self.get_serializer(live_sessions, many=True)
        return Response({
            'status': 'success',
            'count': live_sessions.count(),
            'sessions': serializer.data,
        })

    @action(detail=False, methods=['get'], url_path='video-telemetry')
    def video_telemetry(self, request):
        search = request.query_params.get('search', '').strip()
        tasks = Task.objects.all().order_by('-created_at')
        if search:
            tasks = tasks.filter(Q(title__icontains=search) | Q(video_id__icontains=search))

        live_threshold = timezone.now() - timedelta(seconds=45)
        telemetry_list = []

        for t in tasks:
            sessions = WatchSession.objects.filter(task=t)
            live_count = sessions.filter(
                status=WatchSessionStatus.ACTIVE,
                last_heartbeat_at__gte=live_threshold
            ).count()
            total_users_watched = sessions.values('user').distinct().count()
            total_sec = sessions.aggregate(total=Sum('credited_watch_seconds'))['total'] or 0
            completed_count = TaskAttempt.objects.filter(task=t, reward_granted=True).count()

            telemetry_list.append({
                'id': str(t.id),
                'title': t.title,
                'video_id': t.video_id,
                'source_url': t.source_url,
                'thumbnail_url': t.thumbnail_url or f"https://img.youtube.com/vi/{t.video_id}/hqdefault.jpg",
                'channel_name': t.channel_name,
                'required_watch_seconds': t.required_watch_seconds,
                'reward_coins': t.reward_coins,
                'reward_type': t.reward_type,
                'live_viewers_count': live_count,
                'total_users_watched_count': total_users_watched,
                'total_unique_users_watched': total_users_watched,
                'total_watch_seconds': total_sec,
                'completed_count': completed_count,
            })

        return Response(telemetry_list)

    @action(detail=False, methods=['get'], url_path='video-viewers')
    def video_viewers(self, request):
        video_task_id = request.query_params.get('video_task_id')
        if not video_task_id:
            return Response({
                'status': 'error',
                'message': 'video_task_id query parameter is required',
            }, status=status.HTTP_400_BAD_REQUEST)

        sessions = WatchSession.objects.filter(task_id=video_task_id).select_related('user', 'task', 'attempt').order_by('-started_at')
        live_threshold = timezone.now() - timedelta(seconds=45)

        viewers_list = []
        for s in sessions:
            is_live = (s.status == WatchSessionStatus.ACTIVE and s.last_heartbeat_at and s.last_heartbeat_at >= live_threshold)
            is_completed = (s.status == WatchSessionStatus.COMPLETED or (s.attempt and s.attempt.reward_granted))

            coins_earned = 0
            if s.task:
                if s.task.reward_type == 'per_time':
                    interval = s.task.required_watch_seconds if s.task.required_watch_seconds > 0 else 60
                    coins_earned = (s.credited_watch_seconds // interval) * s.task.reward_coins
                elif is_completed:
                    coins_earned = s.task.reward_coins

            viewers_list.append({
                'session_id': str(s.id),
                'user_id': str(s.user.id) if s.user else '',
                'username': s.user.username if s.user else 'Unknown',
                'email': s.user.email if s.user else '',
                'is_live': bool(is_live),
                'is_completed': bool(is_completed),
                'total_watched_seconds': s.credited_watch_seconds,
                'current_position_seconds': int(s.last_client_position or 0),
                'coins_earned': coins_earned,
                'last_watched_at': (s.last_heartbeat_at or s.started_at).isoformat() if (s.last_heartbeat_at or s.started_at) else None,
                'started_at': s.started_at.isoformat() if s.started_at else None,
            })

        return Response({
            'status': 'success',
            'count': len(viewers_list),
            'viewers': viewers_list,
        })


class AdminUserViewSet(viewsets.ModelViewSet):
    """
    User management, KYC verification, balance adjustment, and account moderation.
    """
    queryset = User.objects.all().order_by('-created_at')
    serializer_class = AdminUserSerializer
    permission_classes = [IsAdminOrStaff]

    def get_queryset(self):
        qs = super().get_queryset()
        query = self.request.query_params.get('q', '').strip()
        if query:
            qs = qs.filter(
                Q(username__icontains=query) |
                Q(email__icontains=query) |
                Q(first_name__icontains=query) |
                Q(last_name__icontains=query)
            )
        return qs

    @action(detail=True, methods=['post'], url_path='adjust-balance')
    def adjust_balance(self, request, pk=None):
        target_user = self.get_object()
        serializer = AdminUserBalanceAdjustmentSerializer(data=request.data)
        if not serializer.is_valid():
            return Response({'status': 'error', 'errors': serializer.errors}, status=status.HTTP_400_BAD_REQUEST)

        currency = serializer.validated_data['currency_type']
        adj_type = serializer.validated_data['adjustment_type']
        amount = serializer.validated_data['amount']
        reason = serializer.validated_data['reason']

        ref = f"ADMIN-ADJ-{request.user.id}-{int(timezone.now().timestamp())}"

        try:
            if currency == 'COINS':
                coin_amount = int(amount)
                if adj_type == 'CREDIT':
                    WalletService.credit_coins(
                        user=target_user,
                        amount=coin_amount,
                        transaction_type=CoinTransactionType.BONUS,
                        reference=ref,
                        description=f"Admin Adjustment: {reason}",
                    )
                else:
                    WalletService.debit_coins(
                        user=target_user,
                        amount=coin_amount,
                        transaction_type=CoinTransactionType.PENALTY,
                        reference=ref,
                        description=f"Admin Debit: {reason}",
                    )
            else:
                if adj_type == 'CREDIT':
                    WalletService.credit_cash(
                        user=target_user,
                        amount=amount,
                        transaction_type=CashTransactionType.BONUS,
                        reference=ref,
                        description=f"Admin Adjustment: {reason}",
                    )
                else:
                    WalletService.debit_cash(
                        user=target_user,
                        amount=amount,
                        transaction_type=CashTransactionType.PENALTY,
                        reference=ref,
                        description=f"Admin Debit: {reason}",
                    )

            target_user.refresh_from_db()
            return Response({
                'status': 'success',
                'message': f"Successfully {adj_type.lower()}ed {amount} {currency} for {target_user.username}.",
                'user': AdminUserSerializer(target_user).data,
            })
        except Exception as e:
            return Response({'status': 'error', 'message': str(e)}, status=status.HTTP_400_BAD_REQUEST)

    @action(detail=True, methods=['post'], url_path='toggle-status')
    def toggle_status(self, request, pk=None):
        target_user = self.get_object()
        target_user.is_active = not target_user.is_active
        target_user.save(update_fields=['is_active'])
        return Response({
            'status': 'success',
            'is_active': target_user.is_active,
            'message': f"User account is now {'Active' if target_user.is_active else 'Suspended'}.",
        })


class AdminWalletTransactionViewSet(viewsets.ReadOnlyModelViewSet):
    """
    Financial audit ledger for all Coin & Cash movements.
    """
    queryset = CoinTransaction.objects.select_related('user').order_by('-created_at')
    serializer_class = AdminCoinTransactionSerializer
    permission_classes = [IsAdminOrStaff]

    def get_queryset(self):
        qs = super().get_queryset()
        tx_type = self.request.query_params.get('type')
        user_id = self.request.query_params.get('user_id')
        if tx_type:
            qs = qs.filter(transaction_type=tx_type.upper())
        if user_id:
            qs = qs.filter(user_id=user_id)
        return qs


class AdminAISettingsView(APIView):
    """
    OpenRouter & Gemini AI Provider management, live model lists, and interactive sandbox.
    """
    permission_classes = [IsAdminOrStaff]

    def get_config(self):
        config = AIProviderConfig.objects.first()
        if not config:
            config = AIProviderConfig.objects.create(
                provider_name='OpenRouter',
                youtube_keyword_model='meta-llama/llama-3.3-70b-instruct:free',
                quiz_generation_model='meta-llama/llama-3.3-70b-instruct:free',
                fraud_analysis_model='meta-llama/llama-3.3-70b-instruct:free',
            )
        return config

    def get(self, request):
        config = self.get_config()
        serializer = AdminAIProviderConfigSerializer(config)
        return Response({
            'status': 'success',
            'config': serializer.data,
        })

    def patch(self, request):
        config = self.get_config()
        serializer = AdminAIProviderConfigSerializer(config, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response({
                'status': 'success',
                'message': 'AI provider configuration saved successfully.',
                'config': serializer.data,
            })
        return Response({'status': 'error', 'errors': serializer.errors}, status=status.HTTP_400_BAD_REQUEST)


class AdminAIFetchModelsView(APIView):
    """
    Dynamically pulls the live 417+ OpenRouter or Gemini models.
    """
    permission_classes = [IsAdminOrStaff]

    def get(self, request):
        provider = request.query_params.get('provider', 'OPENROUTER').upper()
        api_key = request.query_params.get('api_key', '').strip()

        config = AIProviderConfig.objects.first()
        if not api_key and config:
            api_key = config.api_key

        models = fetch_openrouter_models_list(api_key=api_key)
        return Response({
            'status': 'success',
            'count': len(models),
            'models': [{'id': m[0], 'name': m[1]} for m in models],
        })


class AdminAITestSandboxView(APIView):
    """
    Interactive test runner for OpenRouter / Gemini prompt completions and transcript extractions.
    """
    permission_classes = [IsAdminOrStaff]

    def post(self, request):
        serializer = AdminTestPromptSerializer(data=request.data)
        if not serializer.is_valid():
            return Response({'status': 'error', 'errors': serializer.errors}, status=status.HTTP_400_BAD_REQUEST)

        youtube_url = serializer.validated_data.get('youtube_url')
        prompt = serializer.validated_data.get('prompt')

        try:
            if youtube_url:
                meta = extract_youtube_metadata(youtube_url)
                return Response({
                    'status': 'success',
                    'result_type': 'youtube_meta',
                    'data': meta,
                })
            else:
                return Response({
                    'status': 'success',
                    'result_type': 'text_completion',
                    'output': f"Simulated OpenRouter test completion for prompt: '{prompt[:50]}...'",
                })
        except Exception as e:
            return Response({'status': 'error', 'message': str(e)}, status=status.HTTP_400_BAD_REQUEST)
