#!/usr/bin/bash

BASEDIR="$(dirname -- "$(readlink -f -- "$0";)")"
DEBDIR="$BASEDIR/../debian"
CURRENTUSER="$USER"
OUTFILE="$HOME/install.log"

echo "===============================================================================" | tee -a $OUTFILE
echo " Raspi install..." | tee -a $OUTFILE
echo "===============================================================================" | tee -a $OUTFILE

DEV=0

while [[ $# > 0 ]]; do
    key="$1"
    case $key in
        dev)
        DEV=1
        ;;
        *)
        ;;
    esac
    shift
done

# test if sudo is succesfull ==================================================

if [[ "$EUID" = 0 ]]; then
    echo " *** must not be run as root: abort." | tee -a $OUTFILE
    exit 1
else
    sudo -k
    if ! sudo true; then
        echo " *** sudo failed: abort." | tee -a $OUTFILE
        exit 1
    fi
fi

# rpi configuration ===========================================================

dest=/boot/config.txt
if [[ ! -f $dest.bak ]]; then
    echo " *** edit /boot/config.txt" | tee -a $OUTFILE
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
#gpu_mem=256
disable_splash=1

# disable unneeded
dtoverlay=disable-wifi
dtoverlay=disable-bt
EOF
fi

dest=/boot/cmdline.txt
if [[ ! -f $dest.bak ]]; then
    echo " *** edit /boot/cmdline.txt" | tee -a $OUTFILE
    sudo cp $dest $dest.bak 2>&1 | tee -a $OUTFILE
    sudo sed -i 's/ quiet splash plymouth.ignore-serial-consoles//' $dest
fi

# install / remove ============================================================

dest=/usr/bin/mpv
if [[ ! -f $dest ]]; then
    echo " *** install softwares" | tee -a "$OUTFILE"
    
    # update
    sudo apt update && sudo apt full-upgrade 2>&1 | tee -a $OUTFILE
    
    # install base
    APPLIST="build-essential git meson ninja-build libgtk-3-dev libpcre3-dev"
    sudo apt -y install $APPLIST 2>&1 | tee -a "$OUTFILE"
    
    # install softwares
    APPLIST="hsetroot picom rofi thunar xfce4-terminal xfce4-taskmanager mpv"
    APPLIST+=" engrampa p7zip-full numlockx dos2unix cpufrequtils feh"
    sudo apt -y install $APPLIST 2>&1 | tee -a "$OUTFILE"
    
    # install without recommends
    APPLIST="smartmontools"
    sudo apt -y install --no-install-recommends $APPLIST 2>&1 | tee -a $OUTFILE
    
    # uninstall
    APPLIST="bluez dillo lxtask mousepad thonny vim-tiny xarchiver xcompmgr"
    APPLIST+=" system-config-printer tumbler vlc"
    sudo apt -y purge $APPLIST 2>&1 | tee -a "$OUTFILE"
    sudo apt -y autoremove 2>&1 | tee -a "$OUTFILE"
    
    # services
    APPLIST="avahi-daemon colord cups cups-browsed rsyslog triggerhappy"
    APPLIST+=" ModemManager wpa_supplicant"
    sudo systemctl stop $APPLIST 2>&1 | tee -a $OUTFILE
    sudo systemctl disable $APPLIST 2>&1 | tee -a $OUTFILE
    APPLIST="raspi-config"
    sudo systemctl disable $APPLIST 2>&1 | tee -a $OUTFILE
    APPLIST="colord"
    sudo systemctl mask $APPLIST 2>&1 | tee -a $OUTFILE

    # user services
    APPLIST="gvfs-afc-volume-monitor.service"
    APPLIST+=" gvfs-goa-volume-monitor.service"
    APPLIST+=" gvfs-gphoto2-volume-monitor.service"
    APPLIST+=" gvfs-mtp-volume-monitor.service"
    systemctl --user stop $APPLIST 2>&1 | tee -a $OUTFILE
    systemctl --user disable $APPLIST 2>&1 | tee -a $OUTFILE
    systemctl --user mask $APPLIST 2>&1 | tee -a $OUTFILE
fi

# cpu governor ================================================================

dest=/etc/default/cpufrequtils
if [[ ! -f $dest ]]; then
    echo " *** set governor to performance" | tee -a $OUTFILE
    sudo tee $dest > /dev/null << 'EOF'
GOVERNOR="performance"
EOF
fi

# smartd ----------------------------------------------------------------------

if [ "$(pidof smartd)" ]; then
    echo " *** smartd" | tee -a "$OUTFILE"
    sudo systemctl stop smartd 2>&1 | tee -a "$OUTFILE"
    sudo systemctl disable smartd 2>&1 | tee -a "$OUTFILE"
fi

# light-locker ----------------------------------------------------------------

if [ "$(pidof light-locker)" ]; then
    echo " *** light-locker" | tee -a "$OUTFILE"
    sudo apt -y purge light-locker 2>&1 | tee -a "$OUTFILE"
    killall light-locker 2>&1 | tee -a "$OUTFILE"
fi

# user settings ===============================================================

desktop_hide()
{
    local filepath="$HOME/.config/autostart/$1.desktop"
    if [[ ! -f "$filepath" ]]; then
        echo " *** hide $1" | tee -a $OUTFILE
        tee "$filepath" > /dev/null << 'EOF'
[Desktop Entry]
Hidden=true
EOF
    fi
}

dest="$HOME/.config/autostart"
if [[ ! -d $dest ]]; then
    echo " *** create autostart directory" | tee -a $OUTFILE
    mkdir -p $dest 2>&1 | tee -a $OUTFILE
fi

desktop_hide "xcompmgr"
desktop_hide "xdg-user-dirs"
desktop_hide "xdg-user-dirs-kde"
desktop_hide "xfce4-notifyd"
desktop_hide "xiccd"

# config ----------------------------------------------------------------------

dest=~/config
if [[ ! -d $dest ]]; then
    echo " *** config link" | tee -a $OUTFILE
    ln -s ~/.config $dest 2>&1 | tee -a $OUTFILE
fi

# profile ---------------------------------------------------------------------

dest=~/.profile
if ! sudo grep -q "GTK_OVERLAY_SCROLLING" $dest; then
    echo " *** disable overlay scrolling" | tee -a $OUTFILE
    tee -a $dest > /dev/null << 'EOF'
export GTK_OVERLAY_SCROLLING=0
EOF
fi

# aliases ---------------------------------------------------------------------

dest="$HOME"/.bash_aliases
if [[ ! -f "$dest" ]]; then
    echo " *** aliases" | tee -a "$OUTFILE"
    cp "$DEBDIR"/home/bash_aliases "$dest" 2>&1 | tee -a "$OUTFILE"
    echo " *** appfinder" | tee -a "$OUTFILE"
    xfconf-query -c xfce4-appfinder -np /enable-service -t 'bool' -s 'false'
fi

# lxpanel ---------------------------------------------------------------------

dest=~/.config/lxpanel
if [[ -d $dest ]] && [[ ! -d $dest.bak ]]; then
    echo " *** configure panel" | tee -a $OUTFILE
    mv $dest $dest.bak 2>&1 | tee -a $OUTFILE
    mkdir -p $dest 2>&1 | tee -a $OUTFILE
    cp -a $BASEDIR/home/lxpanel/ ~/.config/ 2>&1 | tee -a $OUTFILE
fi

# lxsession -------------------------------------------------------------------

dest=~/.config/lxsession
if [[ ! -d $dest ]]; then
    echo " *** configure session" | tee -a $OUTFILE
    mkdir -p $dest 2>&1 | tee -a $OUTFILE
    cp -a $BASEDIR/home/lxsession/ ~/.config/ 2>&1 | tee -a $OUTFILE
fi

# openbox ---------------------------------------------------------------------

dest=~/.config/openbox
if [[ ! -d $dest ]]; then
    echo " *** configure openbox" | tee -a $OUTFILE
    mkdir -p $dest 2>&1 | tee -a $OUTFILE
    cp -a $BASEDIR/home/openbox/ ~/.config/ 2>&1 | tee -a $OUTFILE
fi

# picom -----------------------------------------------------------------------

dest=~/.config/picom
if [[ ! -d $dest ]]; then
    echo " *** configure picom" | tee -a $OUTFILE
    mkdir -p $dest 2>&1 | tee -a $OUTFILE
    cp $BASEDIR/home/picom.conf "$dest/picom.conf" 2>&1 | tee -a $OUTFILE
fi

# xfwm4 -----------------------------------------------------------------------

if [[ $(pidof xfconfd) ]]; then
    VAL=$(xfconf-query -c xfwm4 -p /general/vblank_mode)
    if [[ $VAL == "auto" ]]; then
        echo " *** set vblank_mode=glx" | tee -a "$OUTFILE"
        xfconf-query -c xfwm4 -p /general/vblank_mode -s "glx" 2>&1 | tee -a "$OUTFILE"
        xfconf-query -c xfwm4 -p /general/workspace_count -s 1 2>&1 | tee -a "$OUTFILE"
    fi
fi

# clean directories -----------------------------------------------------------

dest=~/Images
if [[ -d $dest ]]; then
    echo " *** clean home dir" | tee -a $OUTFILE
    rm -rf ~/Images 2>&1 | tee -a $OUTFILE
    rm -rf ~/Modèles 2>&1 | tee -a $OUTFILE
    rm -rf ~/Musique 2>&1 | tee -a $OUTFILE
    rm -rf ~/Public 2>&1 | tee -a $OUTFILE
    rm -rf ~/Vidéos 2>&1 | tee -a $OUTFILE
fi

# custom session ==============================================================

dest=/usr/bin/startmod
if [[ ! -f $dest ]]; then
    echo " *** startmod script" 2>&1 | tee -a $OUTFILE
    sudo cp $BASEDIR/root/startmod $dest 2>&1 | tee -a $OUTFILE
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
#Session=xfce
#Session=lightdm-xsession
EOF
fi

# install dev =================================================================

if [[ $DEV == 1 ]]; then
    dest=/usr/bin/qtcreator
    if [[ ! -f $dest ]]; then
        echo " *** install dev tools" | tee -a $OUTFILE
        sudo apt -y install qtcreator qtchooser qt5-qmake 2>&1 | tee -a $OUTFILE
        sudo apt -y install qtbase5-dev qtbase5-dev-tools 2>&1 | tee -a $OUTFILE
        sudo apt -y install libgtk-3-dev gtk-3-examples 2>&1 | tee -a $OUTFILE
        sudo apt -y install libprocps-dev libmediainfo-dev 2>&1 | tee -a $OUTFILE
    fi
fi

echo "done" | tee -a $OUTFILE


