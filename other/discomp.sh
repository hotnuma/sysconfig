#!/usr/bin/bash

VAL=$(xfconf-query -c xfwm4 -p /general/use_compositing)

if [[ $VAL == "true" ]]; then
    # enabled
    echo "Disable compositing"
    notify-send -t 3000 "Xfwm4" "Disable compositing"
    xfconf-query -c xfwm4 -p /general/use_compositing -s "false"
else
    # disabled
    echo "Enable compositing"
    notify-send -t 3000 "Xfwm4" "Enable compositing"
    xfconf-query -c xfwm4 -p /general/use_compositing -s "true"
fi


