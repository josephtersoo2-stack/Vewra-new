import os
from django.db import models

class AIProviderConfig(models.Model):
    """
    Dedicated management of OpenRouter API credentials and dynamically fetched model routing.
    """
    id = models.BigAutoField(primary_key=True)
    provider_name = models.CharField(max_length=50, default="OpenRouter")
    api_key = models.CharField(
        max_length=255,
        blank=True,
        help_text="OpenRouter API Key (e.g. sk-or-v1-...)"
    )
    base_url = models.CharField(
        max_length=255,
        default="https://openrouter.ai/api/v1",
        help_text="API Endpoint base URL"
    )

    # Dynamic model IDs selected from OpenRouter API
    youtube_keyword_model = models.CharField(
        max_length=150,
        default="google/gemini-2.0-flash-001",
        help_text="Dynamically fetched OpenRouter model for YouTube transcript & keyword generation"
    )
    quiz_generation_model = models.CharField(
        max_length=150,
        default="openai/gpt-4o-mini",
        help_text="Dynamically fetched OpenRouter model for task quiz questions"
    )
    fraud_analysis_model = models.CharField(
        max_length=150,
        default="anthropic/claude-3.5-haiku",
        help_text="Dynamically fetched OpenRouter model for anti-fraud analysis"
    )

    cached_models = models.JSONField(
        default=list,
        blank=True,
        help_text="Cached list of available models fetched dynamically from OpenRouter API"
    )
    last_models_fetched_at = models.DateTimeField(null=True, blank=True)

    site_url = models.CharField(max_length=200, default="https://vewra.com", help_text="HTTP-Referer header for OpenRouter")
    site_name = models.CharField(max_length=100, default="Vewra Platform", help_text="X-Title header for OpenRouter")
    is_active = models.BooleanField(default=True, help_text="Enable OpenRouter AI features")

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'vewra_ai_provider_config'
        verbose_name = 'OpenRouter AI Provider & Model Config'
        verbose_name_plural = 'OpenRouter AI Provider & Model Configs'

    def __str__(self):
        return f"{self.provider_name} Config ({'Active' if self.is_active else 'Inactive'}) - YouTube Model: {self.youtube_keyword_model}"

    @classmethod
    def get_active_config(cls):
        """
        Retrieves the active OpenRouter configuration or returns a default instance.
        """
        config = cls.objects.filter(is_active=True).first()
        if not config:
            config = cls.objects.create(
                provider_name="OpenRouter",
                is_active=True,
                youtube_keyword_model="google/gemini-2.0-flash-001",
                quiz_generation_model="openai/gpt-4o-mini",
                fraud_analysis_model="anthropic/claude-3.5-haiku",
            )
        return config
