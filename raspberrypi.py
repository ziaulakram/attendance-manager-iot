import RPi.GPIO as GPIO
GPIO.setwarnings(False)
GPIO.setmode(GPIO.BOARD)
from datetime import datetime
from picamera import PiCamera
from time import sleep
from mfrc522 import SimpleMFRC522

import os

import pyrebase

firebaseConfig = {
"apiKey": "AIzaSyDIkdxZCuQyrust4kE8cBs2KKcNtYFwGY4",
"authDomain": "attendancemanagerrpi.firebaseapp.com",
"databaseURL": "https://attendancemanagerrpi-default-rtdb.firebaseio.com",
"projectId": "attendancemanagerrpi",
"storageBucket": "attendancemanagerrpi.appspot.com",
"messagingSenderId": "574478993696",
"appId": "1:574478993696:web:2e7940ffb6c35c557b6f45",
"measurementId": "G-4YWZ1W39FH",
"serviceAccount": "serviceAccount.json",
"databaseURL":"https://attendancemanagerrpi-default-rtdb.firebaseio.com/"
}

firebase = pyrebase.initialize_app(firebaseConfig)

storage = firebase.storage()
database = firebase.database()

camera = PiCamera()

reader = SimpleMFRC522()

try: 
	now = datetime.now()
	dt = now.strftime("%d%m%Y%H:%M:%S")
	name = dt+".jpg"
	print('Place RFID Tag')
	id,text = reader.read()
	camera.capture(name)
	print(name+"saved")
	data = {
	"ID" : id, "Roll No" : text, "Date & Time" : dt
	}
	storage.child(text).put(name)
	print("Image Sent")
	database.push(data)
	os.remove(name)
	GPIO.cleanup()
# 			print('file removed')

except:
	camera.close()

# finally:
# 		GPIO.cleanup()