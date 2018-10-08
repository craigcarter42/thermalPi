# thermalPi
Cron based CPU and GPU tempature monitoring system for the Raspberry Pi platform only.

#### Crontab:
You can set Cron on your system to check at any interval you desire, this system was tested with two minute timing. See instructions below on how to create a custom Crontab.  
crontab -e
sudo bash

#### Python:
Python 2.7 and higher will function. Tested with 3.6

#### Bash:
Code must use Bash to run

#### Config:
 - Set file path at top of program.
 - Set pin number for the control GPIO
 
#### The Fan:
How to wire the fan for sucess not sparks.

### Updating Code:
- Better error logging

