from django import forms
from django.contrib import admin
from django.utils.html import format_html
from .models import AIProviderConfig


class AIProviderConfigForm(forms.ModelForm):
    class Meta:
        model = AIProviderConfig
        fields = '__all__'

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        from apps.tasks.services import fetch_openrouter_models_list
        models_data = fetch_openrouter_models_list()
        if models_data:
            choices = [(m['id'], f"{m['name']} ({m['id']})") for m in models_data]
            for field_name in ['youtube_keyword_model', 'quiz_generation_model', 'fraud_analysis_model']:
                val = self.initial.get(field_name) or getattr(self.instance, field_name, '')
                field_choices = list(choices)
                if val and not any(c[0] == val for c in field_choices):
                    field_choices.insert(0, (val, f"{val} (Custom/Current)"))
                self.fields[field_name].widget = forms.Select(choices=field_choices)


@admin.register(AIProviderConfig)
class AIProviderConfigAdmin(admin.ModelAdmin):
    form = AIProviderConfigForm
    list_display = (
        'provider_name',
        'is_active',
        'youtube_keyword_model',
        'quiz_generation_model',
        'fraud_analysis_model',
        'has_api_key',
        'live_models_count',
        'updated_at',
    )
    list_filter = ('is_active', 'provider_name')
    readonly_fields = ('updated_at', 'created_at', 'connection_test_preview')
    actions = ['refresh_models_action', 'test_openrouter_connection_action']

    fieldsets = (
        ('OpenRouter AI Provider & Credentials', {
            'fields': ('provider_name', 'is_active', 'api_key', 'base_url', 'site_url', 'site_name', 'connection_test_preview'),
            'description': 'Configure your OpenRouter API Key. All 400+ AI models are fetched dynamically live from OpenRouter without any hardcoding.'
        }),
        ('Differentiated Dynamic Model Routing', {
            'fields': ('youtube_keyword_model', 'quiz_generation_model', 'fraud_analysis_model'),
            'description': 'Select from the live list of models fetched directly from OpenRouter API for each specific task.'
        }),
        ('System Timestamps', {
            'fields': ('created_at', 'updated_at'),
            'classes': ('collapse',),
        }),
    )

    @admin.display(description="API Key", boolean=True)
    def has_api_key(self, obj):
        return bool(obj.api_key and len(obj.api_key.strip()) > 8)

    @admin.display(description="OpenRouter Models")
    def live_models_count(self, obj):
        count = len(obj.cached_models) if isinstance(obj.cached_models, list) else 0
        return format_html('<span style="font-weight: bold; color: #3b82f6;">{} live models</span>', count)

    @admin.display(description="Live Connection & Model Status")
    def connection_test_preview(self, obj):
        count = len(obj.cached_models) if isinstance(obj.cached_models, list) else 0
        if not obj.api_key:
            return format_html(
                '<div style="padding: 10px; background: #fff1f2; border: 1px solid #f43f5e; border-radius: 6px;">'
                '<span style="color: #e11d48; font-weight: bold;">⚠️ No API Key configured.</span><br>'
                '<small style="color: #9f1239;">Enter your OpenRouter key to enable automated AI transcript keyword generation.</small><br>'
                '<small style="color: #6b7280;">Live models fetched: <strong>{}</strong></small>'
                '</div>',
                count
            )
        masked = f"{obj.api_key[:6]}...{obj.api_key[-4:]}" if len(obj.api_key) > 10 else "***"
        return format_html(
            '<div style="padding: 10px; background: #ecfdf5; border: 1px solid #10b981; border-radius: 6px;">'
            '<strong style="color: #065f46;">✓ OpenRouter Key Configured:</strong> <code>{}</code><br>'
            '<span style="color: #047857;">Active YouTube Model: <strong>{}</strong></span><br>'
            '<small style="color: #059669;">Total Live OpenRouter Models available: <strong>{}</strong></small>'
            '</div>',
            masked,
            obj.youtube_keyword_model,
            count
        )

    @admin.action(description="🔄 Refresh Live Models List from OpenRouter API")
    def refresh_models_action(self, request, queryset):
        from apps.tasks.services import fetch_openrouter_models_list
        models_data = fetch_openrouter_models_list(force_refresh=True)
        self.message_user(request, f"✓ Successfully fetched and updated {len(models_data)} live models from OpenRouter API.")

    @admin.action(description="🧪 Test OpenRouter Connection & Key")
    def test_openrouter_connection_action(self, request, queryset):
        from apps.tasks.services import call_openrouter
        for config in queryset:
            try:
                test_output = call_openrouter(
                    prompt="Reply with exactly: 'OpenRouter Connected Successfully'",
                    model=config.youtube_keyword_model,
                )
                self.message_user(request, f"✓ Success: {config.provider_name} [{config.youtube_keyword_model}] replied: '{test_output}'")
            except Exception as e:
                self.message_user(request, f"✗ Connection Test Failed for {config.provider_name}: {e}", level='ERROR')
