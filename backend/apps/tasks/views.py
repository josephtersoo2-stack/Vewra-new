import logging
from django.db import transaction
from django.utils import timezone
from django.core.exceptions import ValidationError
from rest_framework import status, permissions
from rest_framework.views import APIView
from rest_framework.response import Response

from .models import (
    Task,
    TaskAttempt,
    TaskAttemptStatus,
    QuizQuestion,
    QuizAttempt,
    QuizAnswer,
)
from .serializers import (
    TaskListSerializer,
    TaskDetailSerializer,
    TaskEligibilitySerializer,
    TaskAttemptSerializer,
    QuizQuestionPublicSerializer,
    QuizSubmissionSerializer,
    QuizResultSerializer,
)
from .selectors import (
    get_available_tasks_for_user,
    get_task_by_id_or_slug,
    get_task_attempt_for_user,
)
from .services import TaskEligibilityService, TaskAttemptService
from apps.tracking.services import WatchSessionService
from apps.tracking.models import WatchSession

logger = logging.getLogger(__name__)

class TaskListView(APIView):
    """API endpoint to list available tasks with optional type filter and keyword search."""
    permission_classes = (permissions.IsAuthenticated,)

    def get(self, request, *args, **kwargs):
        task_type = request.query_params.get('type')
        search = request.query_params.get('search')
        limit = int(request.query_params.get('limit', 50))

        tasks = get_available_tasks_for_user(
            user=request.user,
            task_type=task_type,
            search=search,
            limit=limit,
        )
        serializer = TaskListSerializer(tasks, many=True)
        return Response({
            'status': 'success',
            'count': len(serializer.data),
            'tasks': serializer.data,
        }, status=status.HTTP_200_OK)


class TaskDetailView(APIView):
    """API endpoint to retrieve detailed task metadata and instructions."""
    permission_classes = (permissions.IsAuthenticated,)

    def get(self, request, id, *args, **kwargs):
        try:
            task = get_task_by_id_or_slug(str(id))
            serializer = TaskDetailSerializer(task)
            eligibility = TaskEligibilityService.check(request.user, task)
            return Response({
                'status': 'success',
                'task': serializer.data,
                'eligibility': eligibility,
            }, status=status.HTTP_200_OK)
        except Task.DoesNotExist:
            return Response({
                'status': 'error',
                'code': 'TASK_NOT_FOUND',
                'message': 'Task not found.',
            }, status=status.HTTP_404_NOT_FOUND)


class TaskEligibilityView(APIView):
    """API endpoint to check server-authoritative eligibility for a task."""
    permission_classes = (permissions.IsAuthenticated,)

    def get(self, request, id, *args, **kwargs):
        try:
            task = get_task_by_id_or_slug(str(id))
            eligibility = TaskEligibilityService.check(request.user, task)
            serializer = TaskEligibilitySerializer(eligibility)
            return Response({
                'status': 'success',
                'eligibility': serializer.data,
            }, status=status.HTTP_200_OK)
        except Task.DoesNotExist:
            return Response({
                'status': 'error',
                'code': 'TASK_NOT_FOUND',
                'message': 'Task not found.',
            }, status=status.HTTP_404_NOT_FOUND)


class TaskStartView(APIView):
    """API endpoint to initiate a task attempt and provision a watch session."""
    permission_classes = (permissions.IsAuthenticated,)

    def post(self, request, id, *args, **kwargs):
        try:
            task = get_task_by_id_or_slug(str(id))
            client_platform = request.data.get('client_platform', 'MOBILE')
            app_version = request.data.get('app_version', '1.0.0')
            client_session_id = request.data.get('client_session_id', '')
            device_id = request.data.get('device_id', '')

            with transaction.atomic():
                attempt, created = TaskAttemptService.get_or_create_attempt(request.user, task)
                
                # Check for existing watch session
                session = getattr(attempt, 'watch_session', None)
                if session:
                    # Regenerate secure token for resumed session
                    import secrets, hashlib
                    raw_token = secrets.token_urlsafe(32)
                    session.session_token_hash = hashlib.sha256(raw_token.encode()).hexdigest()
                    session.save(update_fields=['session_token_hash'])
                else:
                    session, raw_token = WatchSessionService.create_session(
                        attempt=attempt,
                        user=request.user,
                        task=task,
                        client_platform=client_platform,
                        app_version=app_version,
                        client_session_id=client_session_id,
                        device_id=device_id,
                    )

            return Response({
                'status': 'success',
                'attempt': TaskAttemptSerializer(attempt).data,
                'watch_session': {
                    'id': str(session.id),
                    'watch_token': raw_token,
                    'required_seconds': session.required_seconds,
                    'credited_watch_seconds': session.credited_watch_seconds,
                    'heartbeat_interval_seconds': 15,
                    'source_url': task.source_url,
                    'channel_name': task.channel_name,
                    'quiz_required': task.quiz_required,
                }
            }, status=status.HTTP_201_CREATED if created else status.HTTP_200_OK)

        except ValidationError as e:
            return Response({
                'status': 'error',
                'code': 'TASK_NOT_ELIGIBLE',
                'message': str(e.message if hasattr(e, 'message') else e),
            }, status=status.HTTP_400_BAD_REQUEST)
        except Task.DoesNotExist:
            return Response({
                'status': 'error',
                'code': 'TASK_NOT_FOUND',
                'message': 'Task not found.',
            }, status=status.HTTP_404_NOT_FOUND)


class TaskAttemptListView(APIView):
    """API endpoint to list authenticated user's task attempts."""
    permission_classes = (permissions.IsAuthenticated,)

    def get(self, request, *args, **kwargs):
        attempts = TaskAttempt.objects.filter(user=request.user).select_related('task')[:50]
        serializer = TaskAttemptSerializer(attempts, many=True)
        return Response({
            'status': 'success',
            'count': len(serializer.data),
            'attempts': serializer.data,
        }, status=status.HTTP_200_OK)


class TaskAttemptDetailView(APIView):
    """API endpoint to retrieve details of a specific attempt."""
    permission_classes = (permissions.IsAuthenticated,)

    def get(self, request, attempt_id, *args, **kwargs):
        try:
            attempt = get_task_attempt_for_user(request.user, str(attempt_id))
            serializer = TaskAttemptSerializer(attempt)
            return Response({
                'status': 'success',
                'attempt': serializer.data,
            }, status=status.HTTP_200_OK)
        except TaskAttempt.DoesNotExist:
            return Response({
                'status': 'error',
                'code': 'ATTEMPT_NOT_FOUND',
                'message': 'Task attempt not found.',
            }, status=status.HTTP_404_NOT_FOUND)


class TaskQuizView(APIView):
    """API endpoint to retrieve quiz questions for an attempt once watch requirement is satisfied."""
    permission_classes = (permissions.IsAuthenticated,)

    def get(self, request, attempt_id, *args, **kwargs):
        try:
            attempt = get_task_attempt_for_user(request.user, str(attempt_id))
            watch_session = getattr(attempt, 'watch_session', None)
            
            # Must satisfy watch requirement first
            if not watch_session or not watch_session.is_watch_satisfied:
                return Response({
                    'status': 'error',
                    'code': 'INSUFFICIENT_WATCH_TIME',
                    'message': 'Watch duration requirement must be satisfied before taking the quiz.',
                }, status=status.HTTP_403_FORBIDDEN)

            questions = attempt.task.quiz_questions.filter(active=True)
            serializer = QuizQuestionPublicSerializer(questions, many=True)
            return Response({
                'status': 'success',
                'attempt_id': str(attempt.id),
                'pass_percentage': attempt.task.quiz_pass_percentage,
                'questions': serializer.data,
            }, status=status.HTTP_200_OK)
        except TaskAttempt.DoesNotExist:
            return Response({
                'status': 'error',
                'code': 'ATTEMPT_NOT_FOUND',
                'message': 'Task attempt not found.',
            }, status=status.HTTP_404_NOT_FOUND)


class TaskQuizSubmitView(APIView):
    """API endpoint to submit answers and evaluate quiz score."""
    permission_classes = (permissions.IsAuthenticated,)

    def post(self, request, attempt_id, *args, **kwargs):
        try:
            attempt = get_task_attempt_for_user(request.user, str(attempt_id))
            watch_session = getattr(attempt, 'watch_session', None)

            if not watch_session or not watch_session.is_watch_satisfied:
                return Response({
                    'status': 'error',
                    'code': 'INSUFFICIENT_WATCH_TIME',
                    'message': 'Watch duration requirement must be satisfied before submitting quiz.',
                }, status=status.HTTP_403_FORBIDDEN)

            serializer = QuizSubmissionSerializer(data=request.data)
            if not serializer.is_valid():
                return Response({
                    'status': 'error',
                    'errors': serializer.errors,
                }, status=status.HTTP_400_BAD_REQUEST)

            submitted_answers = serializer.validated_data['answers']
            questions = {str(q.id): q for q in attempt.task.quiz_questions.filter(active=True)}

            if not questions:
                # If no quiz questions exist, pass automatically
                attempt.quiz_passed = True
                attempt.quiz_score = 100.0
                attempt.save(update_fields=['quiz_passed', 'quiz_score'])
                return Response({
                    'status': 'success',
                    'attempt_id': str(attempt.id),
                    'score': 100.0,
                    'pass_percentage': attempt.task.quiz_pass_percentage,
                    'passed': True,
                    'total_questions': 0,
                    'correct_answers': 0,
                }, status=status.HTTP_200_OK)

            with transaction.atomic():
                quiz_attempt, _ = QuizAttempt.objects.get_or_create(
                    task_attempt=attempt,
                    user=request.user,
                    defaults={'pass_percentage': attempt.task.quiz_pass_percentage}
                )

                correct_count = 0
                for item in submitted_answers:
                    q_id = str(item['question_id'])
                    selected = item['selected_answer'].strip()
                    question = questions.get(q_id)
                    if question:
                        is_correct = selected.lower() == question.correct_answer.strip().lower()
                        if is_correct:
                            correct_count += 1
                        QuizAnswer.objects.update_or_create(
                            quiz_attempt=quiz_attempt,
                            question=question,
                            defaults={'selected_answer': selected, 'is_correct': is_correct}
                        )

                score = round((correct_count / len(questions)) * 100.0, 2)
                passed = score >= attempt.task.quiz_pass_percentage

                quiz_attempt.score = score
                quiz_attempt.passed = passed
                quiz_attempt.submitted_at = timezone.now()
                quiz_attempt.save()

                attempt.quiz_passed = passed
                attempt.quiz_score = score
                if passed:
                    attempt.status = TaskAttemptStatus.VERIFYING
                else:
                    attempt.status = TaskAttemptStatus.FAILED
                    attempt.failure_reason = f"Quiz failed with score {score}% (required {attempt.task.quiz_pass_percentage}%)."
                attempt.save()

            return Response({
                'status': 'success',
                'attempt_id': str(attempt.id),
                'score': score,
                'pass_percentage': attempt.task.quiz_pass_percentage,
                'passed': passed,
                'total_questions': len(questions),
                'correct_answers': correct_count,
            }, status=status.HTTP_200_OK)

        except TaskAttempt.DoesNotExist:
            return Response({
                'status': 'error',
                'code': 'ATTEMPT_NOT_FOUND',
                'message': 'Task attempt not found.',
            }, status=status.HTTP_404_NOT_FOUND)
