#!/usr/bin/bash

# Prepare system -------------------------------------------------------
#
dest=~/DevFiles
if [[ ! -d $dest ]]; then
    mkdir ~/DevFiles
fi

# dependencies
# meson cairo pango libxml2 glib2 wayland-protocols

dest=~/DevFiles/labwc
if [[ ! -d $dest ]]; then
    cd ~/DevFiles
    git clone https://github.com/labwc/labwc.git
else
    cd $dest
    git pull
fi

dest=~/DevFiles/labwc
if [[ -d $dest ]]; then
    if [[ -f ${dest}/build/labwc ]]; then
        rm -rf ${dest}/build
    fi
    cd $dest
    meson build
    ninja -C build
    sudo ninja -C build install
fi


