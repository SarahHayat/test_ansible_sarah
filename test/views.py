from django.shortcuts import render

# Create your views here.
def HomeView(request):
    context = {
        'name': "SARAh"
    }
    return render(request, '', context)