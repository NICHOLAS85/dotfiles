#!/bin/sh

case $1/$2 in
  pre/*)
    akbl --off
    ;;
  post/*)
    echo "Waking up from $2..."
    echo "Triggering alienfxwakeup.sh..."
#    akbl --set-profile Testing
    if on_ac_power; then
        ##Charging, Do something
        akbl --on
        echo "Let there be light! akbl on"
    else
        ##Discharging, Do something
        akbl --off
        echo "You must construct additional pylons! akbl off"
    fi
    ;;
esac
