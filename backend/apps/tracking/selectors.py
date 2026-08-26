from .models import WatchSession

def get_session_for_user(user, session_id: str) -> WatchSession:
    """
    Selects a watch session owned by user.
    """
    return WatchSession.objects.select_related('task', 'attempt').get(id=session_id, user=user)

def get_active_session_for_attempt(attempt_id: str) -> WatchSession:
    """
    Selects the watch session associated with a task attempt.
    """
    return WatchSession.objects.select_related('task', 'attempt').get(attempt_id=attempt_id)
