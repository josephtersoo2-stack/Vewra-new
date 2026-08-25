from rest_framework_simplejwt.tokens import RefreshToken
from django.contrib.auth.tokens import default_token_generator

class AuthService:
    """Service handling token generation and authentication business logic."""

    @staticmethod
    def get_tokens_for_user(user):
        """Generate JWT access and refresh token pair for a user."""
        refresh = RefreshToken.for_user(user)

        # Custom claims for JWT payload
        refresh['username'] = user.username
        refresh['email'] = user.email

        return {
            'refresh': str(refresh),
            'access': str(refresh.access_token),
            'token_type': 'Bearer',
        }

    @staticmethod
    def generate_password_reset_token(user):
        """Generate standard password reset token."""
        return default_token_generator.make_token(user)

    @staticmethod
    def verify_password_reset_token(user, token):
        """Verify token against user instance."""
        return default_token_generator.check_token(user, token)
