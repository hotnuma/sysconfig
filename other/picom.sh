#!/usr/bin/bash

if [[ $(pidof picom) ]]; then
    echo "stop picom"
    notify-send -t 3000 "Picom" "Stop"
    killall picom
else
    echo "start picom"
    notify-send -t 3000 "Picom" "Start"
    picom -b
fi


