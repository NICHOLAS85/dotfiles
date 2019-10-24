#!/bin/sh
case $1 in
  post)
    /usr/bin/autorandr --batch --change && echo "Autorandr: Loaded first detected profile on all active sessions"
    ;;
esac
