#!/bin/sh
case $1 in
  post)
    /usr/bin/autorandr --batch --change && echo "Autorandr: Batch changed"
    ;;
esac
