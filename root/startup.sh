#!/usr/bin/bash

if [[ $XDG_SESSION_TYPE == "x11" ]]; then
    dest="$HOME/.config/wallpaper"
    if [[ -f $dest ]]; then
        hsetroot -cover "$dest"
    else
        hsetroot -solid '#5e5c64'
    fi
    exit 0
fi

if [[ $XDG_SESSION_DESKTOP == "labwc" ]]; then
    echo performance | sudo tee /sys/devices/system/cpu/cpufreq/policy0/scaling_governor
    sleep 2
    sudo systemctl restart systemd-timesyncd.service
    exit 0
fi

