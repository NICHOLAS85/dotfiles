 #!/bin/bash
 
 
TOGGLE=$HOME/.toggle

if [ ! -e $TOGGLE ]; then
    touch $TOGGLE
    
    pkill -f backbrightnessredshiftoff.py
     SCRIPT_PATH="/home/nicholas/Scripts/Startup/backbrightness.py" 
 PYTHON="/usr/bin/python3"
 
 # call script via the interrupter     
 $PYTHON $SCRIPT_PATH -s 0.05 /sys/class/backlight/intel_backlight eDP1 eDP-1 eDP-1-1

else
    rm $TOGGLE
    
    pkill -f backbrightness.py
     SCRIPT_PATH="/home/nicholas/Scripts/Startup/backbrightnessredshiftoff.py" 
 PYTHON="/usr/bin/python3"
 
 # call script via the interrupter     
 $PYTHON $SCRIPT_PATH -s 0.05 /sys/class/backlight/intel_backlight eDP1 eDP-1 eDP-1-1
 
fi

