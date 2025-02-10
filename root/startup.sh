#!/usr/bin/bash

if [[ $XDG_CURRENT_DESKTOP != "XFCE" ]]; then
    exit 0
fi

if [[ ! -f "/usr/bin/hsetroot" ]]; then
    exit 0
fi

dest="$HOME"/wallpaper
if [[ -f $dest ]]; then
    hsetroot -cover "$dest"
    exit 0
fi

hsetroot -solid '#5e5c64'

