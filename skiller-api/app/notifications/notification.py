import firebase_admin
from firebase_admin import credentials, messaging
import os 


credentials_path =  os.getcwd()+'/app/notifications/adminsdk-account-credentials.json'

firebase_credentials = credentials.Certificate(credentials_path)
firebase_app = firebase_admin.initialize_app(firebase_credentials)

def send_notification_to_specific_device(fcm_token : str,title : str, body : str,image:str):
    message = messaging.Message(
      notification=messaging.Notification(
        title=title,
        body=body,
        image = image
      ),
      token=fcm_token,
      )
    response = messaging.send(message,app = firebase_app)
    print('Successfully sent message:', response)
