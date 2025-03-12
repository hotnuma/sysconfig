#!/usr/bin/bash

test "$XDG_CURRENT_DESKTOP" == "XFCE" || exit 0
test "$XDG_SESSION_TYPE" == "x11" || exit 0
which hsetroot || exit 0

dest="$HOME/.config/wallpaper"
if [[ -f $dest ]]; then
    hsetroot -cover "$dest"
    exit 0
fi

hsetroot -solid '#5e5c64'

