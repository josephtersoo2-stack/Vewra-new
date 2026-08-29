from rest_framework import serializers
from .models import Campaign, CampaignType, CampaignStatus


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
