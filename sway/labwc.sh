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
fi

dest=~/DevFiles/labwc
if [[ -d $dest ]]; then
    cd ~/DevFiles/labwc
	meson build
    ninja -C build
    sudo ninja -C build install
fi


