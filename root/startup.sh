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
    dest="/sys/devices/system/cpu/cpufreq/policy0/scaling_governor"
    echo performance | sudo tee "$dest"
    for i in {1..5} ; do
        ping -c1 192.168.1.254 &>/dev/null && break;
        sleep 1
    done
    sudo systemctl restart systemd-timesyncd.service
    exit 0
fi

