#!/usr/bin/bash

BASEDIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
OUTFILE="$HOME/install.log"
OUT="2>&1 | tee -a $OUTFILE"

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
    eval echo "This scrip is not meant to be run as is, it will setup" $OUT
    eval echo "overclocking, remove some programs, install others," $OUT
    eval echo "disable bluetooth, wifi, etc... so it needs to be" $OUT
    eval echo "studied and tweaked to perticuliar needs." $OUT
    eval echo "abort..." $OUT
    exit 1
fi

# test if sudo is succesfull -------------------------------------------------------------

if [[ "$EUID" = 0 ]]; then
    eval echo " *** must not be run as root: abort." $OUT
    exit 1
else
    sudo -k
    if ! sudo true; then
        eval echo " *** sudo failed: abort." $OUT
        exit 1
    fi
fi

if [[ $BASE == 1 ]]; then

    # write config.txt -------------------------------------------------------------------

    dest=/boot/config.txt
    if [[ ! -f $dest.bak ]]; then
        eval echo " *** edit /boot/config.txt" $OUT
        eval sudo cp $dest $dest.bak $OUT
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
        eval echo " *** edit /boot/cmdline.txt" $OUT
        eval sudo cp $dest $dest.bak $OUT
    fi

    # install / remove -------------------------------------------------------------------

    dest=/usr/bin/mpv
    if [[ ! -f $dest ]]; then
        eval echo " *** install softwares" $OUT
        
        # update
        eval sudo apt update && sudo apt full-upgrade $OUT
        eval sudo apt -y install libgtk-3-dev libpcre3-dev $OUT
        
        # install base
        eval sudo apt -y install thunar xfce4-terminal xfce4-taskmanager rofi $OUT
        eval sudo apt -y install mpv engrampa p7zip-full numlockx feh $OUT
        eval sudo apt -y install build-essential git meson ninja-build dos2unix $OUT
        eval sudo apt -y install compton cpufrequtils $OUT
        eval sudo apt -y install --no-install-recommends smartmontools $OUT
        
        # uninstall
        eval sudo apt -y purge bluez dillo thonny vim xarchiver xcompmgr $OUT
        eval sudo apt -y purge system-config-printer lxtask mousepad tumbler $OUT
        
        # services
        eval sudo systemctl stop cups cups-browsed smartd wpa_supplicant $OUT
        eval sudo systemctl disable cups cups-browsed smartd wpa_supplicant $OUT
        eval sudo systemctl stop triggerhappy ModemManager $OUT
        eval sudo systemctl disable raspi-config triggerhappy ModemManager $OUT
        
        # services used by thunar
        eval sudo chmod 0000 /usr/lib/systemd/user/gvfs-afc-volume-monitor.service $OUT
        eval sudo chmod 0000 /usr/lib/systemd/user/gvfs-goa-volume-monitor.service $OUT
        eval sudo chmod 0000 /usr/lib/systemd/user/gvfs-gphoto2-volume-monitor.service $OUT
        eval sudo chmod 0000 /usr/lib/systemd/user/gvfs-mtp-volume-monitor.service $OUT

        # autoremove
        eval sudo apt -y autoremove $OUT
    fi

    # /etc settings ----------------------------------------------------------------------

    dest=/etc/default/cpufrequtils
    if [[ ! -f $dest ]]; then
        eval echo " *** set governor to performance" $OUT
        sudo tee $dest > /dev/null << 'EOF'
GOVERNOR="performance"

EOF
    fi

    # /home settings ---------------------------------------------------------------------

    dest=~/config
    if [[ ! -d $dest ]]; then
        eval echo " *** config link" $OUT
        eval ln -s ~/.config $dest $OUT
    fi

    dest="$XDG_CONFIG_HOME/autostart"
    if [[ ! -d $dest ]]; then
        eval echo " *** create autostart directory" $OUT
        eval mkdir -p $dest $OUT
    fi

    dest=~/.config/lxpanel
    if [[ -d $dest ]] && [[ ! -d $dest.bak ]]; then
        eval echo " *** configure panel" $OUT
        eval mv $dest $dest.bak $OUT
        eval mkdir -p $dest $OUT
        eval cp -a $BASEDIR/config/lxpanel/ ~/.config/ $OUT
    fi

    dest=~/.config/lxsession
    if [[ ! -d $dest ]]; then
        eval echo " *** configure session" $OUT
        eval mkdir -p $dest $OUT
        eval cp -a $BASEDIR/config/lxsession/ ~/.config/ $OUT
    fi

    dest=~/.config/openbox
    if [[ ! -d $dest ]]; then
        eval echo " *** configure openbox" $OUT
        eval mkdir -p $dest $OUT
        eval cp -a $BASEDIR/config/openbox/ ~/.config/ $OUT
    fi

    dest=~/.config/compton.conf
    if [[ ! -f $dest ]]; then
        eval echo " *** configure compton" $OUT
        eval cp $BASEDIR/config/compton.conf $dest $OUT
    fi

    dest=~/Music
    if [[ -d $dest ]]; then
        eval echo " *** clean home dir" $OUT
        eval rm -rf ~/Music $OUT
        eval rm -rf ~/Pictures $OUT
        eval rm -rf ~/Public $OUT
        eval rm -rf ~/Templates $OUT
        eval rm -rf ~/Videos $OUT
    fi

    dest=~/.profile
    if ! sudo grep -q "GTK_OVERLAY_SCROLLING" $dest; then
        eval echo " *** disable overlay scrolling" $OUT
        sudo tee -a $dest > /dev/null << 'EOF'

export GTK_OVERLAY_SCROLLING=0

EOF
    fi

    # custom session ---------------------------------------------------------------------

    dest=/usr/bin/startmod
    if [[ ! -f $dest ]]; then
        eval echo " *** startmod script" $OUT
        eval sudo cp $BASEDIR/../samples/startmod $dest $OUT
    fi

    dest=/usr/share/xsessions/custom.desktop
    if [[ ! -f $dest ]]; then
        eval echo " *** custom session" $OUT
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
        eval echo " *** dmrc" $OUT
        sudo tee $dest > /dev/null << 'EOF'
[Desktop]
Session=custom
EOF
    fi
fi

# install dev ============================================================================

if [[ $DEV == 1 ]]; then
    dest=/usr/bin/qtcreator
    if [[ ! -f $dest ]]; then
        eval echo " *** install dev tools" $OUT
        eval sudo apt -y install qtcreator qtchooser qt5-qmake $OUT
        eval sudo apt -y install qtbase5-dev qtbase5-dev-tools $OUT
        eval sudo apt -y install libgtk-3-dev gtk-3-examples $OUT
        eval sudo apt -y install libprocps-dev libmediainfo-dev $OUT
    fi
fi


