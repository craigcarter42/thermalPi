#!/bin/bash
# Craig Carter 2018, box256
# Configuration:
# Path to directory 
  sys_path="/home/pi/..."
# Set the threshold for fan power on:
  gold_temp="45"

# Load config files:
# -- Check current fan state:
  current_state="`sed -n 1p $sys_path/current_fan_state.txt`"
# -- Logging YES or NO:
  logging="`sed -n 1p $sys_path/logging.conf`"

# Get date and time:
  current_date=$(date '+%d/%m/%Y %H:%M:%S');

# Thermal Check
# -- CPU:
  cpu_temp=$(</sys/class/thermal/thermal_zone0/temp)
  cpu_temp_final="$((cpu_temp/1000))"
  echo " thermalPi -- CPU temp: $cpu_temp_final"
# -- GPU:
  gpu_temp=$(/opt/vc/bin/vcgencmd measure_temp | awk -F "[=\\.']" '{print $2}')
  echo " thermalPi -- GPU temp: $gpu_temp"

# Cron Snitch: log each launch:
  echo " thermalPi -- launch: "$current_date >> $sys_path/cron_launch.log
  echo " thermalPi -- fan state: "$current_state >> $sys_path/cron_launch.log

# Generate and update log file for system status information:
system_log() {
# Update current state:
  current_state="`sed -n 1p $sys_path/current_fan_state.txt`"
# Generate Log:
  echo " thermalPi -- status check" >> $sys_path/activity.log
  echo " ---- current date: $current_date" >> $sys_path/activity.log
  echo " fan state: "$current_state >> $sys_path/activity.log
  echo " CPU temperature: "$cpu_temp_final >> $sys_path/activity.log
  echo " GPU temperature: "$gpu_temp >> $sys_path/activity.log
}

if [ "$cpu_temp_final" -ge "$gold_temp" ]; then
    echo " thermalPi -- fan = ON"
    python $sys_path/fan_power.py on
    echo "on" > $sys_path/current_fan_state.txt
    if [ "$logging" == "on" ]; then
      system_log "'running' --continue"
    fi
    exit
else
    if [ "$current_state" -eq "off" ]; then
        echo " thermalPi -- fan = OFF"
        echo "off" > $sys_path/current_fan_state.txt
        if [ "$logging" == "on" ]; then
          system_log "'standby' --exit"
        fi
        exit
    else
        python $sys_path/fan_power.py off
        echo "off" > $sys_path/current_fan_state.txt
        if [ "$logging" == "on" ]; then
          system_log "'standby' --exit"
        fi
        exit
    fi
fi
