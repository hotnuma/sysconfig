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

# set no password sudo -------------------------------------------------

dest=/etc/sudoers.d/custom
if [[ ! -f $dest ]]; then
    echo "*** edit /etc/sudoers"
    sudo tee $dest > /dev/null << 'EOF'
hotnuma ALL=(ALL) NOPASSWD: ALL

EOF
fi

# startup.sh --------- -------------------------------------------------

dest=/usr/local/bin/startup.sh
if [[ ! -f $dest ]]; then
    echo "*** autostart"
    sudo cp $BASEDIR/local/bin/startup.sh $dest
    cp -r $BASEDIR/home/config/autostart/* $HOME/.config/autostart/ 
fi

# install / remove -----------------------------------------------------

dest=/usr/bin/mpv
if [[ ! -f $dest ]]; then
    echo "*** install softwares"
    
    # uninstall snaps
    sudo rm -rf /var/cache/snapd/
    sudo apt -y purge snapd gnome-software-plugin-snap
    rm -rf ~/snap
    
    # install base
    sudo apt -y install hsetroot htop net-tools rofi xfce4-taskmanager
    sudo apt -y install lm-sensors hardinfo p7zip-full engrampa geany
    sudo apt -y install mpv mkvtoolnix mkvtoolnix-gui mediainfo-gui
    sudo apt -y install build-essential git meson ninja-build dos2unix
    sudo apt -y install gimp
    sudo apt -y install --no-install-recommends smartmontools
    
    # uninstall
    sudo apt -y purge xfce4-power-manager xfce4-screensaver tumbler
    sudo apt -y purge synaptic thunderbird fwupd thermald at-spi2-core
    
    # services
    sudo systemctl stop bluetooth cups cups-browsed wpa_supplicant
    sudo systemctl stop unattended-upgrades
    sudo systemctl disable bluetooth cups cups-browsed wpa_supplicant
    sudo systemctl disable unattended-upgrades

    sudo apt -y autoremove
fi

# install dev apps -----------------------------------------------------

dest=/usr/bin/qtcreator
if [[ ! -f $dest ]]; then
    echo "*** install dev softwares"
    
    # install dev
    sudo apt -y install qtcreator qtchooser qtbase5-dev qt5-qmake qtbase5-dev-tools
    sudo apt -y install libgtk-3-dev gtk-3-examples libmediainfo-dev libprocps-dev
    
fi


