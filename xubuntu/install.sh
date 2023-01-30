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

CURRENTUSER=$USER
dest=/etc/sudoers.d/custom
if [[ ! -f $dest ]]; then
    echo "*** sudoers" 2>&1 | tee -a $OUTFILE
    sudo tee $dest > /dev/null << EOF
$CURRENTUSER ALL=(ALL) NOPASSWD: ALL
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

dest=/usr/bin/htop
if [[ ! -f $dest ]]; then
    echo "*** install softwares" 2>&1 | tee -a $OUTFILE
    
    # uninstall snaps
    sudo rm -rf /var/cache/snapd/ 2>&1 | tee -a $OUTFILE
    sudo apt -y purge snapd gnome-software-plugin-snap 2>&1 | tee -a $OUTFILE
    rm -rf ~/snap 2>&1 | tee -a $OUTFILE
    
    # install base
    APPLIST="htop hsetroot geany hardinfo lm-sensors net-tools xfce4-taskmanager"
    APPLIST+=" p7zip-full engrampa mpv mkvtoolnix mkvtoolnix-gui mediainfo-gui"
    APPLIST+=" gimp evince rofi"
    APPLIST+=" build-essential git meson ninja-build dos2unix"
    sudo apt -y install $APPLIST 2>&1 | tee -a $OUTFILE
    
    APPLIST="--no-install-recommends smartmontools"
    sudo apt -y install $APPLIST 2>&1 | tee -a $OUTFILE
    
    # uninstall
    APPLIST="thunderbird synaptic xfce4-power-manager xfce4-screensaver tumbler"
    APPLIST+=" at-spi2-core fwupd thermald geoclue-2.0 printer-driver-foo2zjs-common"
    sudo apt -y purge $APPLIST 2>&1 | tee -a $OUTFILE
    
    # services
    APPLIST="cups cups-browsed bluetooth wpa_supplicant unattended-upgrades"
    sudo systemctl stop $APPLIST 2>&1 | tee -a $OUTFILE
    sudo systemctl disable $APPLIST 2>&1 | tee -a $OUTFILE

    sudo apt -y autoremove 2>&1 | tee -a $OUTFILE
fi

# install dev apps -------------------------------------------------------------

dest=/usr/bin/qtcreator
if [[ ! -f $dest ]]; then
    echo "*** install dev softwares" 2>&1 | tee -a $OUTFILE
    
    # install dev
    APPLIST="qtcreator qtchooser qtbase5-dev qt5-qmake qtbase5-dev-tools"
    APPLIST+=" libgtk-3-dev gtk-3-examples libmediainfo-dev libprocps-dev"
    sudo apt -y install $APPLIST 2>&1 | tee -a $OUTFILE
fi

# Hide Launchers ---------------------------------------------------------------

dest=$HOME/.local/share/applications/
if [[ ! -d $dest ]]; then
    echo "*** create .local/share/applications/" 2>&1 | tee -a $OUTFILE
    mkdir -p $dest 2>&1 | tee -a $OUTFILE
fi

dest=/usr/local/bin/appinfo
if [[ -f $dest ]]; then
    dest=$HOME/.local/share/applications/xfce4-appfinder.desktop
    if [[ ! -f $dest ]]; then
        echo "*** hide launchers" 2>&1 | tee -a $OUTFILE
        appinfo -h "debian-uxterm" 2>&1 | tee -a $OUTFILE
        appinfo -h "debian-xterm" 2>&1 | tee -a $OUTFILE
        appinfo -h "gcr-prompter" 2>&1 | tee -a $OUTFILE
        appinfo -h "gcr-viewer" 2>&1 | tee -a $OUTFILE
        appinfo -h "org.gnome.Evince-previewer" 2>&1 | tee -a $OUTFILE
        appinfo -h "RealTimeSync" 2>&1 | tee -a $OUTFILE
        appinfo -h "xfce4-appfinder" 2>&1 | tee -a $OUTFILE
        appinfo -h "xfce4-file-manager" 2>&1 | tee -a $OUTFILE
        appinfo -h "xfce4-mail-reader" 2>&1 | tee -a $OUTFILE
        appinfo -h "xfce4-run" 2>&1 | tee -a $OUTFILE
        appinfo -h "xfce-backdrop-settings" 2>&1 | tee -a $OUTFILE
    fi
fi


