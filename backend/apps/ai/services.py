import logging
import requests
from apps.ai.models import AIProviderConfig

logger = logging.getLogger(__name__)

OPENROUTER_MODELS_API_URL = "https://openrouter.ai/api/v1/models"


def fetch_openrouter_models_list(api_key: str = None) -> list[tuple[str, str]]:
    """
    Fetches the live list of models from OpenRouter API.
    Returns list of (model_id, model_name) tuples.
    """
    headers = {
        "HTTP-Referer": "https://vewra.com",
        "X-Title": "VEWRA Platform",
    }
    if api_key:
        headers["Authorization"] = f"Bearer {api_key}"
    else:
        config = AIProviderConfig.objects.first()
        if config and config.openrouter_api_key:
            headers["Authorization"] = f"Bearer {config.openrouter_api_key}"

    try:
        response = requests.get(OPENROUTER_MODELS_API_URL, headers=headers, timeout=10)
        if response.status_code == 200:
            data = response.json()
            models_data = data.get("data", [])
            choices = []
            for item in models_data:
                m_id = item.get("id", "")
                m_name = item.get("name", m_id)
                pricing = item.get("pricing", {})
                is_free = pricing.get("prompt") == "0" and pricing.get("completion") == "0"
                display_label = f"{m_name} (FREE)" if is_free else f"{m_name} ({m_id})"
                choices.append((m_id, display_label))
            
            choices.sort(key=lambda x: (not x[0].endswith(":free"), x[1].lower()))
            if choices:
                return choices
    except Exception as e:
        logger.warning("Could not fetch live OpenRouter models: %s", e)

    return [
        ("meta-llama/llama-3.3-70b-instruct:free", "Llama 3.3 70B Instruct (FREE)"),
        ("google/gemini-2.0-flash-exp:free", "Gemini 2.0 Flash Exp (FREE)"),
        ("google/gemini-flash-1.5:free", "Gemini Flash 1.5 (FREE)"),
        ("deepseek/deepseek-r1:free", "DeepSeek R1 (FREE)"),
        ("mistralai/mistral-7b-instruct:free", "Mistral 7B Instruct (FREE)"),
        ("openai/gpt-4o-mini", "GPT-4o Mini"),
        ("openai/gpt-4o", "GPT-4o"),
        ("anthropic/claude-3.5-sonnet", "Claude 3.5 Sonnet"),
    ]
