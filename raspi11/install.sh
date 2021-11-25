#!/usr/bin/bash

BASEDIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

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

dest=/boot/config.txt
if [[ ! -f $dest.bak ]]; then
    echo "*** edit /boot/config.txt"
    sudo cp $dest $dest.bak
    sudo tee $dest > /dev/null << 'EOF'
# http://rpf.io/configtxt

disable_overscan=1

# overclock
arm_freq=2000
gpu_freq=600
over_voltage=6

# enable audio
dtparam=audio=on

# enable DRM VC4 V3D drive
dtoverlay=vc4-kms-v3d
max_framebuffers=2
arm_64bit=1
gpu_mem=256
disable_splash=1

# disable unneeded
dtoverlay=disable-wifi
dtoverlay=disable-bt

EOF
fi

# install / remove -----------------------------------------------------

dest=/usr/bin/mpv
if [[ ! -f $dest ]]; then
    echo "*** install softwares"
    
    # update
    sudo apt update && sudo apt full-upgrade
    
    # install base
    sudo apt -y install thunar xfce4-terminal xfce4-taskmanager rofi
    sudo apt -y install firefox-esr webext-ublock-origin-firefox
    sudo apt -y install mpv engrampa p7zip-full numlockx feh
    sudo apt -y install build-essential git meson ninja-build dos2unix
    sudo apt -y install cpufrequtils
    sudo apt -y install --no-install-recommends smartmontools
	
	# uninstall
    sudo apt -y purge thonny vim xarchiver system-config-printer
    sudo apt -y purge lxtask mousepad tumbler
    
    # services
    sudo systemctl stop bluetooth cups cups-browsed wpa_supplicant
    sudo systemctl disable bluetooth cups cups-browsed wpa_supplicant
    sudo systemctl stop triggerhappy
    sudo systemctl disable triggerhappy raspi-config

    # autoremove
    sudo apt -y autoremove
fi

# /etc settings
dest=/etc/default/cpufrequtils
if [[ ! -f $dest ]]; then
    echo "*** set governor to performance"
    sudo tee $dest > /dev/null << 'EOF'
GOVERNOR="performance"

EOF
fi

# /home settings
dest=~/config
if [[ ! -d $dest ]]; then
    echo "*** config link"
    ln -s ~/.config $dest
fi

#TODO : append 'export GTK_OVERLAY_SCROLLING=0' into ~/.profile

dest=~/.config/lxpanel
if [[ ! -d $dest ]]; then
    echo "*** configure panel"
    
    mkdir -p $dest
    cp -a $BASEDIR/config/lxpanel/ ~/.config/
fi

dest=~/.config/lxsession
if [[ ! -d $dest ]]; then
    echo "*** configure session"
    
    mkdir -p $dest
    cp -a $BASEDIR/config/lxsession/ ~/.config/
fi

dest=~/.config/openbox
if [[ ! -d $dest ]]; then
    echo "*** configure openbox"
    mkdir -p $dest
    cp -a $BASEDIR/config/openbox/ ~/.config/
fi


