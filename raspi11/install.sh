#!/usr/bin/bash

BASEDIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        dev)
        DEV=1
        shift
        ;;
        *)
        shift
        ;;
    esac
done


# test if sudo is succesfull -------------------------------------------

if [[ "$EUID" = 0 ]]; then
    echo " *** must not be run as root: abort."
    exit 1
else
    sudo -k # make sure to ask for password on next sudo
    if ! sudo true; then
        echo " *** sudo failed: abort."
        exit 1
    fi
fi

# write config.txt -----------------------------------------------------

dest=/boot/config.txt
if [[ ! -f $dest.bak ]]; then
    echo " *** edit /boot/config.txt"
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

dest=/boot/cmdline.txt
if [[ ! -f $dest.bak ]]; then
    echo " *** edit /boot/cmdline.txt"
    sudo cp $dest $dest.bak
fi

# install / remove -----------------------------------------------------

dest=/usr/bin/mpv
if [[ ! -f $dest ]]; then
    echo " *** install softwares"
    
    # update
    sudo apt update && sudo apt full-upgrade
    
    # install base
    sudo apt -y install thunar xfce4-terminal xfce4-taskmanager rofi
    sudo apt -y install mpv engrampa p7zip-full numlockx feh
    sudo apt -y install build-essential git meson ninja-build dos2unix
    sudo apt -y install compton cpufrequtils
    sudo apt -y install --no-install-recommends smartmontools
	
	# uninstall
    sudo apt -y purge bluez dillo thonny vim xarchiver xcompmgr
    sudo apt -y purge system-config-printer lxtask mousepad tumbler
    
    # services
    # bluetooth is already disabled
    sudo systemctl stop cups cups-browsed smartd wpa_supplicant
    sudo systemctl disable cups cups-browsed smartd wpa_supplicant
    sudo systemctl stop triggerhappy ModemManager
    sudo systemctl disable raspi-config triggerhappy ModemManager
    
    # services used by thunar
    sudo chmod 0000 /usr/lib/systemd/user/gvfs-afc-volume-monitor.service
    sudo chmod 0000 /usr/lib/systemd/user/gvfs-goa-volume-monitor.service
    sudo chmod 0000 /usr/lib/systemd/user/gvfs-gphoto2-volume-monitor.service
    sudo chmod 0000 /usr/lib/systemd/user/gvfs-mtp-volume-monitor.service

    # autoremove
    sudo apt -y autoremove
fi

# install dev ----------------------------------------------------------

if [[ $DEV == 1 ]]; then
    dest=/usr/bin/qtcreator
    if [[ ! -f $dest ]]; then
        echo " *** install dev tools"
        sudo apt -y install qtcreator qtchooser qtbase5-dev qt5-qmake qtbase5-dev-tools
        sudo apt -y install libgtk-3-dev gtk-3-examples libmediainfo-dev
        sudo apt -y install libprocps-dev
    fi
fi

# /etc settings --------------------------------------------------------

dest=/etc/default/cpufrequtils
if [[ ! -f $dest ]]; then
    echo " *** set governor to performance"
    sudo tee $dest > /dev/null << 'EOF'
GOVERNOR="performance"

EOF
fi

# /home settings -------------------------------------------------------

dest=~/config
if [[ ! -d $dest ]]; then
    echo " *** config link"
    ln -s ~/.config $dest
fi

dest=~/.config/lxpanel
if [[ -d $dest ]] && [[ ! -d $dest.bak ]]; then
    echo " *** configure panel"
    mv $dest $dest.bak
    mkdir -p $dest
    cp -a $BASEDIR/config/lxpanel/ ~/.config/
fi

dest=~/.config/lxsession
if [[ ! -d $dest ]]; then
    echo " *** configure session"
    mkdir -p $dest
    cp -a $BASEDIR/config/lxsession/ ~/.config/
fi

dest=~/.config/openbox
if [[ ! -d $dest ]]; then
    echo " *** configure openbox"
    mkdir -p $dest
    cp -a $BASEDIR/config/openbox/ ~/.config/
fi

dest=~/.config/compton.conf
if [[ ! -f $dest ]]; then
    echo " *** configure compton"
    cp $BASEDIR/config/compton.conf $dest
fi

dest=~/Music
if [[ -d $dest ]]; then
    echo " *** clean home dir"
    rm -rf ~/Music
    rm -rf ~/Pictures
    rm -rf ~/Public
    rm -rf ~/Templates
    rm -rf ~/Videos
fi

dest=~/.profile
if ! sudo grep -q "GTK_OVERLAY_SCROLLING" $dest; then
    echo " *** disable overlay scrolling"
    sudo tee -a $dest > /dev/null << 'EOF'

export GTK_OVERLAY_SCROLLING=0

EOF
fi

# custom session -------------------------------------------------------

dest=/usr/bin/startmod
if [[ ! -f $dest ]]; then
    echo " *** startmod script"
    sudo cp $BASEDIR/../samples/startmod $dest
fi

dest=/usr/share/xsessions/custom.desktop
if [[ ! -f $dest ]]; then
    echo " *** custom session"
    sudo tee $dest > /dev/null << 'EOF'
[Desktop Entry]
Name=LXDE
Comment=LXDE - Lightweight X11 desktop environment
Exec=/usr/bin/startmod
Type=Application
EOF
fi

dest=~/.dmrc
if [[ ! -f $dest ]]; then
    echo " *** dmrc"
    sudo tee $dest > /dev/null << 'EOF'
[Desktop]
Session=custom
EOF
fi

# test -----------------------------------------------------------------

test=0
if [[ $test == 1 ]]; then
    echo " *** run test"
fi


