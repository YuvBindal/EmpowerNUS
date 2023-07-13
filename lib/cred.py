import firebase_admin
from firebase_admin import credentials

cred = credentials.Certificate('/Users/reetmitra/Desktop/EmpowerNUS\ Main/lib/test-project-123842-firebase-adminsdk-41s69-6f963ed033.json')
default_app = firebase_admin.initialize_app(cred)
