import RPi.GPIO as GPIO
import sys

GPIO.setmode(GPIO.BCM)
GPIO.setwarnings(False)
GPIO.setup(18,GPIO.OUT)

args = str(sys.argv[1:2])

if(args == "['on']"):
	print(" thermalPi -- fan = ON")
    GPIO.output(18,GPIO.HIGH)
    exit
elif(args == "['off']"):
    print(" thermalPi -- fan = OFF")
    GPIO.output(18,GPIO.LOW)
    exit
else:
    print(" thermalPi -- ERROR")
    # print to error.log
    exit
