from django.db.models import Q
from .models import Task, TaskStatus, TaskAttempt

def get_available_tasks_for_user(user=None, task_type=None, search=None, limit=50):
    """
    Selects active tasks available in the catalog with optional type filter and search keyword querying.
    """
    queryset = Task.objects.filter(status=TaskStatus.ACTIVE)

    if task_type:
        queryset = queryset.filter(task_type=task_type.upper())

    if search:
        s = search.strip()
        queryset = queryset.filter(
            Q(title__icontains=s) |
            Q(description__icontains=s) |
            Q(channel_name__icontains=s) |
            Q(search_keywords__icontains=s)
        )

    return queryset.order_by('-created_at')[:limit]

def get_task_by_id_or_slug(identifier: str) -> Task:
    """
    Resolves task entity by either UUID pk or slug.
    """
    try:
        return Task.objects.get(id=identifier)
    except (Task.DoesNotExist, ValueError):
        return Task.objects.get(slug=identifier)

def get_task_attempt_for_user(user, attempt_id: str) -> TaskAttempt:
    """
    Resolves task attempt owned by user.
    """
    return TaskAttempt.objects.get(id=attempt_id, user=user)
