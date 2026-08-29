import logging
from django.core.exceptions import ValidationError
from rest_framework import status, permissions
from rest_framework.views import APIView
from rest_framework.response import Response

from .models import WatchSession
from .serializers import (
    WatchSessionSerializer,
    WatchHeartbeatSerializer,
    WatchEventInputSerializer,
)
from .selectors import get_session_for_user
from .services import (
    HeartbeatProcessingService,
    TrackingEventService,
    TrackingVerificationService,
)

logger = logging.getLogger(__name__)

def _get_watch_token(request) -> str:
    """Extract watch token from header or body."""
    return (
        request.headers.get('X-VEWRA-WATCH-TOKEN') or
        request.META.get('HTTP_X_VEWRA_WATCH_TOKEN') or
        request.data.get('watch_token') or
        ''
    ).strip()


class WatchSessionDetailView(APIView):
    """API endpoint to get current server tracking state of a watch session."""
    permission_classes = (permissions.IsAuthenticated,)

    def get(self, request, id, *args, **kwargs):
        try:
            session = get_session_for_user(request.user, str(id))
            serializer = WatchSessionSerializer(session)
            return Response({
                'status': 'success',
                'session': serializer.data,
            }, status=status.HTTP_200_OK)
        except WatchSession.DoesNotExist:
            return Response({
                'status': 'error',
                'code': 'SESSION_NOT_FOUND',
                'message': 'Watch session not found.',
            }, status=status.HTTP_404_NOT_FOUND)


class WatchHeartbeatView(APIView):
    """API endpoint to process periodic watch heartbeats and credit valid time."""
    permission_classes = (permissions.IsAuthenticated,)

    def post(self, request, id, *args, **kwargs):
        token = _get_watch_token(request)
        if not token:
            return Response({
                'status': 'error',
                'code': 'SESSION_TOKEN_REQUIRED',
                'message': 'X-VEWRA-WATCH-TOKEN header is required for heartbeat tracking.',
            }, status=status.HTTP_401_UNAUTHORIZED)

        serializer = WatchHeartbeatSerializer(data=request.data)
        if not serializer.is_valid():
            return Response({
                'status': 'error',
                'errors': serializer.errors,
            }, status=status.HTTP_400_BAD_REQUEST)

        try:
            result = HeartbeatProcessingService.process_heartbeat(
                session_id=str(id),
                user=request.user,
                token=token,
                sequence=serializer.validated_data['sequence'],
                playback_position=serializer.validated_data.get('playback_position'),
                client_timestamp=serializer.validated_data.get('client_timestamp'),
                is_google_authenticated=serializer.validated_data.get('is_google_authenticated', True),
            )
            return Response(result, status=status.HTTP_200_OK)
        except ValidationError as e:
            return Response({
                'status': 'error',
                'code': 'INVALID_SEQUENCE',
                'message': str(e.message if hasattr(e, 'message') else e),
            }, status=status.HTTP_400_BAD_REQUEST)
        except WatchSession.DoesNotExist:
            return Response({
                'status': 'error',
                'code': 'SESSION_NOT_FOUND',
                'message': 'Watch session not found.',
            }, status=status.HTTP_404_NOT_FOUND)


class WatchEventView(APIView):
    """API endpoint to log player and app lifecycle events."""
    permission_classes = (permissions.IsAuthenticated,)

    def post(self, request, id, *args, **kwargs):
        token = _get_watch_token(request)
        if not token:
            return Response({
                'status': 'error',
                'code': 'SESSION_TOKEN_REQUIRED',
                'message': 'X-VEWRA-WATCH-TOKEN header is required.',
            }, status=status.HTTP_401_UNAUTHORIZED)

        serializer = WatchEventInputSerializer(data=request.data)
        if not serializer.is_valid():
            return Response({
                'status': 'error',
                'errors': serializer.errors,
            }, status=status.HTTP_400_BAD_REQUEST)

        try:
            result = TrackingEventService.process_event(
                session_id=str(id),
                user=request.user,
                token=token,
                event_type=serializer.validated_data['event_type'],
                sequence=serializer.validated_data['sequence'],
                playback_position=serializer.validated_data.get('playback_position'),
                metadata=serializer.validated_data.get('metadata'),
            )
            return Response(result, status=status.HTTP_200_OK)
        except ValidationError as e:
            return Response({
                'status': 'error',
                'code': 'EVENT_PROCESSING_ERROR',
                'message': str(e.message if hasattr(e, 'message') else e),
            }, status=status.HTTP_400_BAD_REQUEST)
        except WatchSession.DoesNotExist:
            return Response({
                'status': 'error',
                'code': 'SESSION_NOT_FOUND',
                'message': 'Watch session not found.',
            }, status=status.HTTP_404_NOT_FOUND)


class WatchCompletionView(APIView):
    """API endpoint to request server completion verification and reward settlement."""
    permission_classes = (permissions.IsAuthenticated,)

    def post(self, request, id, *args, **kwargs):
        token = _get_watch_token(request)
        if not token:
            return Response({
                'status': 'error',
                'code': 'SESSION_TOKEN_REQUIRED',
                'message': 'X-VEWRA-WATCH-TOKEN header is required.',
            }, status=status.HTTP_401_UNAUTHORIZED)

        try:
            result = TrackingVerificationService.verify_completion(
                session_id=str(id),
                user=request.user,
                token=token,
            )
            return Response(result, status=status.HTTP_200_OK)
        except ValidationError as e:
            return Response({
                'status': 'error',
                'code': 'VERIFICATION_ERROR',
                'message': str(e.message if hasattr(e, 'message') else e),
            }, status=status.HTTP_400_BAD_REQUEST)
        except WatchSession.DoesNotExist:
            return Response({
                'status': 'error',
                'code': 'SESSION_NOT_FOUND',
                'message': 'Watch session not found.',
            }, status=status.HTTP_404_NOT_FOUND)


class WatchAbandonView(APIView):
    """API endpoint to explicitly abandon an in-progress session."""
    permission_classes = (permissions.IsAuthenticated,)

    def post(self, request, id, *args, **kwargs):
        token = _get_watch_token(request)
        try:
            result = TrackingVerificationService.abandon_session(
                session_id=str(id),
                user=request.user,
                token=token,
            )
            return Response(result, status=status.HTTP_200_OK)
        except ValidationError as e:
            return Response({
                'status': 'error',
                'message': str(e.message if hasattr(e, 'message') else e),
            }, status=status.HTTP_400_BAD_REQUEST)
        except WatchSession.DoesNotExist:
            return Response({
                'status': 'error',
                'code': 'SESSION_NOT_FOUND',
                'message': 'Watch session not found.',
            }, status=status.HTTP_404_NOT_FOUND)
