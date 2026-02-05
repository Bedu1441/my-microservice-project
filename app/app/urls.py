from django.http import HttpResponse
from django.urls import path

def health(request):
    return HttpResponse("OK")

urlpatterns = [
    path('', health),
]
