import firebase_admin
from firebase_admin import auth

# Initialize the default app
default_app = firebase_admin.initialize_app()

uid = '3IobvQTEl4ZVapDacMkLPNrQfpw1'  # Replace with the UID of the user

try:
    user_record = auth.get_user(uid)
    print('Successfully fetched user data: {0}'.format(user_record))
except Exception as e:
    print('Error fetching user data: {0}'.format(e))
