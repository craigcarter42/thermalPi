#!/bin/bash
# Craig Carter 2018, box256
# Configuration:
# Path to directory
  sys_path="/home/pi/thermalPi"
# Set the threshold for fan power on:
  gold_temp="45"

# Load config files:
# -- Check current fan state:
  if [ -e $sys_path/current_fan_state.txt ]; then
     current_state="`sed -n 1p $sys_path/current_fan_state.txt`"
  else
    touch $sys_path/current_fan_state.txt
  fi
# -- Logging YES or NO:
  if [ -e $sys_path/logging.conf ]; then
    logging="`sed -n 1p $sys_path/logging.conf`"
  else
    touch $sys_path/logging.conf
  fi

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

# Check CPU temp vs. gold temp
  if [ "$cpu_temp_final" -ge  "$gold_temp" ]; then
    echo " thermalPi -- start fan"
    python $sys_path/fan_power.py on
    echo "on" > $sys_path/current_fan_state.txt
    if [ "$logging" == "on" ]; then
      system_log "'running' --continue"
    else
      echo " thermalPi -- logging = OFF"
    fi
# Exit scipt::
    exit
  else
# What is the fans current state?
    if [ "$current_state" == "off" ]; then # -eq or ==
        echo " thermalPi -- halt fan"
        echo "off" > $sys_path/current_fan_state.txt
        if [ "$logging" == "on" ]; then
          system_log "'standby' --exit"
        else
          echo " thermalPi -- logging = OFF"
        fi
        exit
    else
        python $sys_path/fan_power.py off
        echo "off" > $sys_path/current_fan_state.txt
        if [ "$logging" == "on" ]; then
          system_log "'standby' --exit"
        else
          echo " thermalPi -- logging = OFF"
        fi
        exit
    fi
  fi
