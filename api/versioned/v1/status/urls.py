from django.conf.urls import url
from .views import HealthCheckViewSet

urlpatterns = [
    url(r'^health-check$', HealthCheckViewSet.as_view({'get': 'get_status'}))
]