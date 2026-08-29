import os
import uuid
import mimetypes
from typing import Dict, Any, Tuple
from django.core.exceptions import ValidationError
from django.core.files.uploadedfile import UploadedFile
from PIL import Image
import io

from .models import MediaType


class MediaValidationService:
    """
    Validates uploaded campaign media assets (videos, images, banners)
    enforcing file integrity, strict extension whitelists, MIME type verification,
    and size constraints.
    """

    MAX_IMAGE_SIZE_BYTES = 10 * 1024 * 1024   # 10 MB
    MAX_VIDEO_SIZE_BYTES = 500 * 1024 * 1024  # 500 MB

    ALLOWED_IMAGE_EXTENSIONS = {".jpg", ".jpeg", ".png", ".webp"}
    ALLOWED_VIDEO_EXTENSIONS = {".mp4", ".mov"}

    ALLOWED_IMAGE_MIMES = {"image/jpeg", "image/png", "image/webp"}
    ALLOWED_VIDEO_MIMES = {"video/mp4", "video/quicktime"}

    DISALLOWED_EXTENSIONS = {
        ".exe", ".bat", ".cmd", ".sh", ".php", ".py", ".js", ".html",
        ".htm", ".jsp", ".asp", ".aspx", ".dll", ".so", ".bin", ".vbs"
    }

    @classmethod
    def validate_and_inspect_file(
        cls,
        uploaded_file: UploadedFile,
        media_type: str,
    ) -> Dict[str, Any]:
        """
        Performs comprehensive server-side security checks on an uploaded file.
        Returns a dictionary containing validated metadata:
        {
            'file_size': int,
            'mime_type': str,
            'width': Optional[int],
            'height': Optional[int],
            'duration_seconds': Optional[int],
            'sanitized_filename': str,
        }
        Raises ValidationError if any security check fails.
        """
        if not uploaded_file:
            raise ValidationError({"file": "No media file was provided."})

        filename = uploaded_file.name or "upload"
        _, ext = os.path.splitext(filename.lower())

        if ext in cls.DISALLOWED_EXTENSIONS:
            raise ValidationError({"file": f"Executable or script files ({ext}) are strictly forbidden."})

        file_size = uploaded_file.size
        if file_size <= 0:
            raise ValidationError({"file": "Uploaded file is empty (0 bytes)."})

        # Determine media category and validate size & extension
        is_video = (media_type == MediaType.VIDEO)
        is_image = (media_type in [MediaType.IMAGE, MediaType.BANNER])

        if is_video:
            if ext not in cls.ALLOWED_VIDEO_EXTENSIONS:
                raise ValidationError({
                    "file": f"Invalid video extension '{ext}'. Allowed extensions: {', '.join(cls.ALLOWED_VIDEO_EXTENSIONS)}"
                })
            if file_size > cls.MAX_VIDEO_SIZE_BYTES:
                raise ValidationError({
                    "file": f"Video file exceeds maximum allowed size of 500MB (actual: {file_size / (1024*1024):.1f}MB)."
                })
        elif is_image:
            if ext not in cls.ALLOWED_IMAGE_EXTENSIONS:
                raise ValidationError({
                    "file": f"Invalid image extension '{ext}'. Allowed extensions: {', '.join(cls.ALLOWED_IMAGE_EXTENSIONS)}"
                })
            if file_size > cls.MAX_IMAGE_SIZE_BYTES:
                raise ValidationError({
                    "file": f"Image file exceeds maximum allowed size of 10MB (actual: {file_size / (1024*1024):.1f}MB)."
                })
        else:
            raise ValidationError({"media_type": f"Unsupported media type '{media_type}'."})

        # Content-type verification
        guessed_mime, _ = mimetypes.guess_type(filename)
        mime_type = uploaded_file.content_type or guessed_mime or "application/octet-stream"

        if is_video and mime_type not in cls.ALLOWED_VIDEO_MIMES:
            # Fallback check if browser sent generic video or application type with valid extension
            if not mime_type.startswith("video/") and guessed_mime not in cls.ALLOWED_VIDEO_MIMES:
                raise ValidationError({"file": f"Invalid video MIME type '{mime_type}'."})

        if is_image and mime_type not in cls.ALLOWED_IMAGE_MIMES:
            if not mime_type.startswith("image/") and guessed_mime not in cls.ALLOWED_IMAGE_MIMES:
                raise ValidationError({"file": f"Invalid image MIME type '{mime_type}'."})

        # Extract image dimensions if image/banner
        width = None
        height = None
        if is_image:
            try:
                # Read header without loading whole file into memory
                uploaded_file.seek(0)
                image = Image.open(uploaded_file)
                image.verify()  # Verify image integrity
                
                # Reopen to get size (verify closes/invalidates the image)
                uploaded_file.seek(0)
                image = Image.open(uploaded_file)
                width, height = image.size
                uploaded_file.seek(0)
            except Exception as e:
                raise ValidationError({"file": "Uploaded image file appears corrupted or invalid."})

        sanitized_filename = f"{uuid.uuid4().hex[:12]}_{os.path.basename(filename)}"

        return {
            "file_size": file_size,
            "mime_type": mime_type,
            "width": width,
            "height": height,
            "duration_seconds": None,
            "sanitized_filename": sanitized_filename,
        }
