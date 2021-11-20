#!/usr/bin/bash

# install dev apps -----------------------------------------------------

dest=/usr/bin/qtcreator
if [[ ! -f $dest ]]; then
    echo "*** install dev softwares"
    
	# install dev
	sudo apt -y install qtcreator qtchooser qtbase5-dev qt5-qmake qtbase5-dev-tools
	sudo apt -y install libgtk-3-dev gtk-3-examples libmediainfo-dev libprocps-dev
	
fi


