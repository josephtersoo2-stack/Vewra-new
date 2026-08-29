from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static

# Custom Django Admin Branding
admin.site.site_header = "VEWRA Administration Portal"
admin.site.site_title = "VEWRA Admin"
admin.site.index_title = "Platform Management & Video Tasks Dashboard"

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/v1/auth/', include('apps.authentication.urls')),
    path('api/v1/authentication/', include('apps.authentication.urls')),
    path('api/v1/users/', include('apps.users.urls')),
    path('api/v1/security/', include('apps.security.urls')),
    path('api/v1/subscriptions/', include('apps.subscriptions.urls')),
    path('api/v1/wallet/', include('apps.wallet.urls')),
    path('api/v1/tasks/', include('apps.tasks.urls')),
    path('api/v1/tracking/', include('apps.tracking.urls')),
    path('api/v1/campaigns/', include('apps.campaigns.urls')),
    path('api/v1/admin/', include('apps.admin_api.urls')),
]

if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
    urlpatterns += static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)
