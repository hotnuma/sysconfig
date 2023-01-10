#!/usr/bin/bash

BASEDIR="$(dirname -- "$(readlink -f -- "$0";)")"
OUTFILE="$HOME/install.log"
rm -f $OUTFILE

# test if sudo is succesfull ---------------------------------------------------

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

# sudoers ----------------------------------------------------------------------

CURRENT_USER=$USER
dest=/etc/sudoers.d/custom
if [[ ! -f $dest ]]; then
    echo "*** sudoers" 2>&1 | tee -a $OUTFILE
    sudo tee $dest > /dev/null << EOF
$CURRENT_USER ALL=(ALL) NOPASSWD: ALL
EOF
fi

# environment ------------------------------------------------------------------

dest=/etc/environment
if [[ ! -f ${dest}.bak ]]; then
    echo "*** environment" 2>&1 | tee -a $OUTFILE
    sudo cp $dest ${dest}.bak 2>&1 | tee -a $OUTFILE
    sudo cp $BASEDIR/root/environment $dest 2>&1 | tee -a $OUTFILE
fi

# autostart --------------------------------------------------------------------

dest=/usr/local/bin/startup.sh
if [[ ! -f $dest ]]; then
    echo "*** autostart" 2>&1 | tee -a $OUTFILE
    sudo cp $BASEDIR/root/startup.sh $dest 2>&1 | tee -a $OUTFILE
    cp -r $BASEDIR/home/config/autostart/* $HOME/.config/autostart/ 2>&1 | tee -a $OUTFILE
fi

# autologin --------------------------------------------------------------------

dest=/etc/lightdm/lightdm.conf
if [[ ! -f ${dest}.bak ]]; then
    echo "*** autologin" 2>&1 | tee -a $OUTFILE
    sudo cp $dest ${dest}.bak 2>&1 | tee -a $OUTFILE
    sudo cp $BASEDIR/root/lightdm.conf $dest 2>&1 | tee -a $OUTFILE
fi

# startxfce4 -------------------------------------------------------------------

dest=/usr/bin/startxfce4
if [[ ! -f ${dest}.bak ]]; then
    echo "*** startxfce4" 2>&1 | tee -a $OUTFILE
    sudo mv $dest ${dest}.bak 2>&1 | tee -a $OUTFILE
    sudo cp $BASEDIR/root/startxfce4 $dest 2>&1 | tee -a $OUTFILE
fi

# install / remove -------------------------------------------------------------

dest=/usr/bin/mpv
if [[ ! -f $dest ]]; then
    echo "*** install softwares" 2>&1 | tee -a $OUTFILE
    
    # uninstall snaps
    sudo rm -rf /var/cache/snapd/ 2>&1 | tee -a $OUTFILE
    sudo apt -y purge snapd gnome-software-plugin-snap 2>&1 | tee -a $OUTFILE
    rm -rf ~/snap 2>&1 | tee -a $OUTFILE
    
    # install base
    sudo apt -y install hsetroot htop net-tools rofi xfce4-taskmanager 2>&1 | tee -a $OUTFILE
    sudo apt -y install lm-sensors hardinfo p7zip-full engrampa geany 2>&1 | tee -a $OUTFILE
    sudo apt -y install mpv mkvtoolnix mkvtoolnix-gui mediainfo-gui 2>&1 | tee -a $OUTFILE
    sudo apt -y install build-essential git meson ninja-build dos2unix 2>&1 | tee -a $OUTFILE
    sudo apt -y install gimp 2>&1 | tee -a $OUTFILE
    sudo apt -y install --no-install-recommends smartmontools 2>&1 | tee -a $OUTFILE
    
    # uninstall
    sudo apt -y purge xfce4-power-manager xfce4-screensaver tumbler 2>&1 | tee -a $OUTFILE
    sudo apt -y purge synaptic thunderbird fwupd thermald at-spi2-core 2>&1 | tee -a $OUTFILE
    
    # services
    sudo systemctl stop bluetooth cups cups-browsed wpa_supplicant 2>&1 | tee -a $OUTFILE
    sudo systemctl stop unattended-upgrades
    sudo systemctl disable bluetooth cups cups-browsed wpa_supplicant 2>&1 | tee -a $OUTFILE
    sudo systemctl disable unattended-upgrades 2>&1 | tee -a $OUTFILE

    sudo apt -y autoremove 2>&1 | tee -a $OUTFILE
fi

# install dev apps -------------------------------------------------------------

dest=/usr/bin/qtcreator
if [[ ! -f $dest ]]; then
    echo "*** install dev softwares" 2>&1 | tee -a $OUTFILE
    
    # install dev
    sudo apt -y install qtcreator qtchooser qtbase5-dev qt5-qmake qtbase5-dev-tools 2>&1 | tee -a $OUTFILE
    sudo apt -y install libgtk-3-dev gtk-3-examples libmediainfo-dev libprocps-dev 2>&1 | tee -a $OUTFILE
    
fi


