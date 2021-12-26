#!/usr/bin/bash

BASEDIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
OUTFILE="$HOME/install.log"

rm -f $OUTFILE

BASE=0
DEV=0

while [[ $# > 0 ]]; do
    key="$1"
    case $key in
        base)
        BASE=1
        shift
        ;;
        dev)
        DEV=1
        shift
        ;;
        *)
        shift
        ;;
    esac
done

ALL=$(( $BASE + $DEV ))

if [[ $ALL < 1 ]]; then
    echo "This scrip is not meant to be run as is, it will setup" 2>&1 | tee -a $OUTFILE
    echo "overclocking, remove some programs, install others," 2>&1 | tee -a $OUTFILE
    echo "disable bluetooth, wifi, etc... so it needs to be" 2>&1 | tee -a $OUTFILE
    echo "studied and tweaked to perticuliar needs." 2>&1 | tee -a $OUTFILE
    echo "abort..." 2>&1 | tee -a $OUTFILE
    exit 1
fi

# test if sudo is succesfull -------------------------------------------------------------

if [[ "$EUID" = 0 ]]; then
    echo " *** must not be run as root: abort." 2>&1 | tee -a $OUTFILE
    exit 1
else
    sudo -k
    if ! sudo true; then
        echo " *** sudo failed: abort." 2>&1 | tee -a $OUTFILE
        exit 1
    fi
fi

if [[ $BASE == 1 ]]; then

    # write config.txt -------------------------------------------------------------------

    dest=/boot/config.txt
    if [[ ! -f $dest.bak ]]; then
        echo " *** edit /boot/config.txt" 2>&1 | tee -a $OUTFILE
        sudo cp $dest $dest.bak 2>&1 | tee -a $OUTFILE
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
        echo " *** edit /boot/cmdline.txt" 2>&1 | tee -a $OUTFILE
        sudo cp $dest $dest.bak 2>&1 | tee -a $OUTFILE
        sudo sed -i 's/ quiet splash plymouth.ignore-serial-consoles//' $dest
    fi

    # install / remove -------------------------------------------------------------------

    dest=/usr/bin/mpv
    if [[ ! -f $dest ]]; then
        echo " *** install softwares" 2>&1 | tee -a $OUTFILE
        
        # update
        sudo apt update && sudo apt full-upgrade 2>&1 | tee -a $OUTFILE
        sudo apt -y install libgtk-3-dev libpcre3-dev 2>&1 | tee -a $OUTFILE
        
        # install base
        sudo apt -y install thunar xfce4-terminal xfce4-taskmanager rofi 2>&1 | tee -a $OUTFILE
        sudo apt -y install mpv engrampa p7zip-full numlockx feh 2>&1 | tee -a $OUTFILE
        sudo apt -y install build-essential git meson ninja-build dos2unix 2>&1 | tee -a $OUTFILE
        sudo apt -y install compton cpufrequtils 2>&1 | tee -a $OUTFILE
        sudo apt -y install --no-install-recommends smartmontools 2>&1 | tee -a $OUTFILE
        
        # uninstall
        sudo apt -y purge vim-tiny bluez dillo thonny xarchiver xcompmgr 2>&1 | tee -a $OUTFILE
        sudo apt -y purge system-config-printer lxtask mousepad tumbler 2>&1 | tee -a $OUTFILE
        
        # services
        sudo systemctl stop cups cups-browsed smartd wpa_supplicant 2>&1 | tee -a $OUTFILE
        sudo systemctl disable cups cups-browsed smartd wpa_supplicant 2>&1 | tee -a $OUTFILE
        sudo systemctl stop triggerhappy ModemManager 2>&1 | tee -a $OUTFILE
        sudo systemctl disable raspi-config triggerhappy ModemManager 2>&1 | tee -a $OUTFILE
        
        # services used by thunar
        sudo chmod 0000 /usr/lib/systemd/user/gvfs-afc-volume-monitor.service 2>&1 | tee -a $OUTFILE
        sudo chmod 0000 /usr/lib/systemd/user/gvfs-goa-volume-monitor.service 2>&1 | tee -a $OUTFILE
        sudo chmod 0000 /usr/lib/systemd/user/gvfs-gphoto2-volume-monitor.service 2>&1 | tee -a $OUTFILE
        sudo chmod 0000 /usr/lib/systemd/user/gvfs-mtp-volume-monitor.service 2>&1 | tee -a $OUTFILE

        # autoremove
        sudo apt -y autoremove 2>&1 | tee -a $OUTFILE
    fi

    # /etc settings ----------------------------------------------------------------------

    dest=/etc/default/cpufrequtils
    if [[ ! -f $dest ]]; then
        echo " *** set governor to performance" 2>&1 | tee -a $OUTFILE
        sudo tee $dest > /dev/null << 'EOF'
GOVERNOR="performance"

EOF
    fi

    # /home settings ---------------------------------------------------------------------

    dest=~/config
    if [[ ! -d $dest ]]; then
        echo " *** config link" 2>&1 | tee -a $OUTFILE
        ln -s ~/.config $dest 2>&1 | tee -a $OUTFILE
    fi

    dest="$XDG_CONFIG_HOME/autostart"
    if [[ ! -d $dest ]]; then
        echo " *** create autostart directory" 2>&1 | tee -a $OUTFILE
        mkdir -p $dest 2>&1 | tee -a $OUTFILE
    fi

    dest=~/.config/lxpanel
    if [[ -d $dest ]] && [[ ! -d $dest.bak ]]; then
        echo " *** configure panel" 2>&1 | tee -a $OUTFILE
        mv $dest $dest.bak 2>&1 | tee -a $OUTFILE
        mkdir -p $dest 2>&1 | tee -a $OUTFILE
        cp -a $BASEDIR/config/lxpanel/ ~/.config/ 2>&1 | tee -a $OUTFILE
    fi

    dest=~/.config/lxsession
    if [[ ! -d $dest ]]; then
        echo " *** configure session" 2>&1 | tee -a $OUTFILE
        mkdir -p $dest 2>&1 | tee -a $OUTFILE
        cp -a $BASEDIR/config/lxsession/ ~/.config/ 2>&1 | tee -a $OUTFILE
    fi

    dest=~/.config/openbox
    if [[ ! -d $dest ]]; then
        echo " *** configure openbox" 2>&1 | tee -a $OUTFILE
        mkdir -p $dest 2>&1 | tee -a $OUTFILE
        cp -a $BASEDIR/config/openbox/ ~/.config/ 2>&1 | tee -a $OUTFILE
    fi

    dest=~/.config/compton.conf
    if [[ ! -f $dest ]]; then
        echo " *** configure compton" 2>&1 | tee -a $OUTFILE
        cp $BASEDIR/config/compton.conf $dest 2>&1 | tee -a $OUTFILE
    fi

    dest=~/Music
    if [[ -d $dest ]]; then
        echo " *** clean home dir" 2>&1 | tee -a $OUTFILE
        rm -rf ~/Music 2>&1 | tee -a $OUTFILE
        rm -rf ~/Pictures 2>&1 | tee -a $OUTFILE
        rm -rf ~/Public 2>&1 | tee -a $OUTFILE
        rm -rf ~/Templates 2>&1 | tee -a $OUTFILE
        rm -rf ~/Videos 2>&1 | tee -a $OUTFILE
    fi

    dest=~/.profile
    if ! sudo grep -q "GTK_OVERLAY_SCROLLING" $dest; then
        echo " *** disable overlay scrolling" 2>&1 | tee -a $OUTFILE
        tee -a $dest > /dev/null << 'EOF'

export GTK_OVERLAY_SCROLLING=0

EOF
    fi

    # custom session ---------------------------------------------------------------------

dest=/usr/bin/startmod
if [[ ! -f $dest ]]; then
    echo "*** startmod script" 2>&1 | tee -a $OUTFILE
    sudo cp $BASEDIR/config/startmod $dest 2>&1 | tee -a $OUTFILE
fi

    dest=/usr/share/xsessions/custom.desktop
    if [[ ! -f $dest ]]; then
        echo " *** custom session" 2>&1 | tee -a $OUTFILE
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
        echo " *** dmrc" 2>&1 | tee -a $OUTFILE
        tee $dest > /dev/null << 'EOF'
[Desktop]
Session=custom
EOF
    fi
fi

# install dev ============================================================================

if [[ $DEV == 1 ]]; then
    dest=/usr/bin/qtcreator
    if [[ ! -f $dest ]]; then
        echo " *** install dev tools" 2>&1 | tee -a $OUTFILE
        sudo apt -y install qtcreator qtchooser qt5-qmake 2>&1 | tee -a $OUTFILE
        sudo apt -y install qtbase5-dev qtbase5-dev-tools 2>&1 | tee -a $OUTFILE
        sudo apt -y install libgtk-3-dev gtk-3-examples 2>&1 | tee -a $OUTFILE
        sudo apt -y install libprocps-dev libmediainfo-dev 2>&1 | tee -a $OUTFILE
    fi
fi


