#!/usr/bin/bash

# Prepare system -------------------------------------------------------
#
dest=~/DevFiles
if [[ ! -d $dest ]]; then
    mkdir ~/DevFiles
fi

# needs these
# sudo pacman -S wayland-protocols

dest=~/DevFiles/labwc
if [[ ! -d $dest ]]; then
    cd ~/DevFiles
	git clone https://github.com/labwc/labwc.git
	cd labwc
	meson build
    ninja -C build
    sudo ninja -C build install
fi


