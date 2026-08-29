from rest_framework import serializers
from .models import Campaign, CampaignType, CampaignStatus, CampaignMedia, MediaType, MediaStatus


class CampaignOwnerSerializer(serializers.Serializer):
    id = serializers.CharField(read_only=True)
    email = serializers.EmailField(read_only=True)
    username = serializers.CharField(read_only=True)


class CampaignSerializer(serializers.ModelSerializer):
    """
    Standard read and representation serializer for Campaign entity.
    """
    owner_details = serializers.SerializerMethodField()
    status_display = serializers.CharField(source="get_status_display", read_only=True)
    campaign_type_display = serializers.CharField(source="get_campaign_type_display", read_only=True)

    class Meta:
        model = Campaign
        fields = [
            "id",
            "owner",
            "owner_details",
            "campaign_type",
            "campaign_type_display",
            "title",
            "description",
            "status",
            "status_display",
            "budget",
            "start_date",
            "end_date",
            "created_at",
            "updated_at",
        ]
        read_only_fields = [
            "id",
            "owner",
            "status",
            "created_at",
            "updated_at",
        ]

    def get_owner_details(self, obj) -> dict:
        if not obj.owner:
            return {}
        return {
            "id": str(obj.owner.id),
            "email": obj.owner.email,
            "username": getattr(obj.owner, "username", obj.owner.email),
        }


class CampaignCreateSerializer(serializers.Serializer):
    """
    Input serializer for creating a new Campaign in DRAFT status.
    """
    campaign_type = serializers.ChoiceField(choices=CampaignType.choices, default=CampaignType.TASK)
    title = serializers.CharField(max_length=255, required=True)
    description = serializers.CharField(required=False, allow_blank=True, default="")
    budget = serializers.DecimalField(max_digits=12, decimal_places=2, required=False, default="0.00")
    start_date = serializers.DateTimeField(required=False, allow_null=True)
    end_date = serializers.DateTimeField(required=False, allow_null=True)

    def validate(self, attrs):
        start = attrs.get("start_date")
        end = attrs.get("end_date")
        if start and end and end <= start:
            raise serializers.ValidationError({"end_date": "End date must be after start date."})
        return attrs


class CampaignStatusActionSerializer(serializers.Serializer):
    """
    Serializer for administrative or owner status transitions.
    """
    reason = serializers.CharField(required=False, allow_blank=True, default="")


class CampaignMediaSerializer(serializers.ModelSerializer):
    """
    Serializer representing CampaignMedia creative assets (video, banner, image).
    """
    media_type_display = serializers.CharField(source="get_media_type_display", read_only=True)
    status_display = serializers.CharField(source="get_status_display", read_only=True)
    file_url = serializers.SerializerMethodField()
    thumbnail_url = serializers.SerializerMethodField()
    file_size_formatted = serializers.SerializerMethodField()
    uploaded_by_email = serializers.SerializerMethodField()

    class Meta:
        model = CampaignMedia
        fields = [
            "id",
            "campaign",
            "media_type",
            "media_type_display",
            "file",
            "file_url",
            "thumbnail",
            "thumbnail_url",
            "title",
            "description",
            "file_size",
            "file_size_formatted",
            "mime_type",
            "duration_seconds",
            "width",
            "height",
            "status",
            "status_display",
            "uploaded_by",
            "uploaded_by_email",
            "created_at",
            "updated_at",
        ]
        read_only_fields = [
            "id",
            "file_size",
            "mime_type",
            "duration_seconds",
            "width",
            "height",
            "uploaded_by",
            "created_at",
            "updated_at",
        ]

    def get_file_url(self, obj) -> str:
        request = self.context.get("request")
        if obj.file and hasattr(obj.file, "url"):
            if request is not None:
                return request.build_absolute_uri(obj.file.url)
            return obj.file.url
        return ""

    def get_thumbnail_url(self, obj) -> str:
        request = self.context.get("request")
        if obj.thumbnail and hasattr(obj.thumbnail, "url"):
            if request is not None:
                return request.build_absolute_uri(obj.thumbnail.url)
            return obj.thumbnail.url
        return ""

    def get_file_size_formatted(self, obj) -> str:
        size = obj.file_size
        if size < 1024:
            return f"{size} B"
        elif size < 1024 * 1024:
            return f"{size / 1024:.1f} KB"
        return f"{size / (1024 * 1024):.2f} MB"

    def get_uploaded_by_email(self, obj) -> str:
        return obj.uploaded_by.email if obj.uploaded_by else ""


class CampaignMediaUploadSerializer(serializers.Serializer):
    """
    Multipart input serializer for uploading and attaching a media asset.
    """
    file = serializers.FileField(required=True)
    media_type = serializers.ChoiceField(choices=MediaType.choices, required=True)
    title = serializers.CharField(max_length=255, required=True)
    description = serializers.CharField(required=False, allow_blank=True, default="")


class CampaignMediaUpdateSerializer(serializers.Serializer):
    """
    Serializer for modifying metadata on an existing CampaignMedia asset.
    """
    title = serializers.CharField(max_length=255, required=False)
    description = serializers.CharField(required=False, allow_blank=True)
    status = serializers.ChoiceField(choices=MediaStatus.choices, required=False)
