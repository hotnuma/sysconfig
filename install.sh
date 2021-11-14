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

# set no password sudo -------------------------------------------------

dest=/etc/sudoers.d/custom
if [[ ! -f $dest ]]; then
    echo "*** edit /etc/sudoers"
    sudo tee -a $dest > /dev/null << 'EOF'

hotnuma ALL=(ALL) NOPASSWD: ALL

EOF
fi

# install / remove -----------------------------------------------------

# dconf-editor 

dest=/usr/bin/htop
if [[ ! -f $dest ]]; then
    echo "*** install softwares"
    
    # uninstall snaps
	sudo rm -rf /var/cache/snapd/
	sudo apt -y purge snapd gnome-software-plugin-snap
	rm -rf ~/snap
	
    # install base
    sudo apt -y install htop geany rofi gimp xfce4-taskmanager net-tools
    sudo apt -y install p7zip-full engrampa lm-sensors hardinfo gparted
	sudo apt -y install mpv mkvtoolnix mkvtoolnix-gui mediainfo-gui
    sudo apt -y install --no-install-recommends smartmontools
	
	# uninstall
    sudo apt -y purge xfce4-power-manager xfce4-screensaver tumbler
    sudo apt -y purge synaptic thunderbird fwupd thermald at-spi2-core
    
    # services
	sudo systemctl disable bluetooth cups cups-browsed unattended-upgrades
    sudo systemctl disable wpa_supplicant
	
	sudo apt -y autoremove
fi

# install dev apps -----------------------------------------------------

dest=/usr/bin/qtcreator
if [[ ! -f $dest ]]; then
    echo "*** install dev softwares"
    
	# install dev
    sudo apt -y install build-essential git ninja-build dos2unix
	sudo apt -y install qtcreator qtchooser qtbase5-dev qt5-qmake qtbase5-dev-tools
	sudo apt -y install libgtk-3-dev gtk-3-examples libmediainfo-dev libprocps-dev
	
fi


