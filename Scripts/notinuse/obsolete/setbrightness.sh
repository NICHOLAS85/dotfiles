#!/bin/bash

location="36.02:-78.95"

if wget -q --spider 1.1.1.1; then
    redshift -p geoclue2
fi
 

TOGGLE=$HOME/.toggle
PYTHON="/usr/bin/python3"

if [ ! -e $TOGGLE ]; then
    touch $TOGGLE
    
    pkill -f backbrightnessredshiftoff.py
     SCRIPT_PATH="/home/nicholas/Scripts/Startup/backbrightness.py" 

 # call script via the interrupter     
 $PYTHON $SCRIPT_PATH -s 0.2 /sys/class/backlight/intel_backlight eDP1 eDP-1 eDP-1-1

else
    rm $TOGGLE
    
    pkill -f backbrightness.py
     SCRIPT_PATH="/home/nicholas/Scripts/Startup/backbrightnessredshiftoff.py" 
 
 # call script via the interrupter     
 $PYTHON $SCRIPT_PATH -s 0.2 /sys/class/backlight/intel_backlight eDP1 eDP-1 eDP-1-1
 
fi

