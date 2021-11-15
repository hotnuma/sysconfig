#!/bin/bash

# test if sudo is succesfull -------------------------------------------

if [[ "$EUID" = 0 ]]; then
    echo "*** must not be run as root: abort."
    exit 1
else
    sudo -k # make sure to ask for password on next sudo
    if ! sudo true; then
        echo "*** sudo failed: abort."
        exit 1
    fi
fi

# install dev apps -----------------------------------------------------

dest=/usr/bin/qtcreator
if [[ ! -f $dest ]]; then
    echo "*** install dev softwares"
    
	# install dev
	sudo apt -y install qtcreator qtchooser qtbase5-dev qt5-qmake qtbase5-dev-tools
	sudo apt -y install libgtk-3-dev gtk-3-examples
	
fi


