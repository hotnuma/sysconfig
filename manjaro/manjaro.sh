#!/usr/bin/bash

BASEDIR="$(dirname -- "$(readlink -f -- "$0";)")"
DEBDIR="$BASEDIR/../debian"
CURRENTUSER="$USER"
OUTFILE="$HOME/install.log"

echo "===============================================================================" | tee -a $OUTFILE
echo " Manjaro install..." | tee -a $OUTFILE
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

# sudoers ---------------------------------------------------------------------

dest=/etc/sudoers.d/010_pi-nopasswd
if ! sudo grep -q "!logfile" $dest; then
    echo " *** sudoers" | tee -a "$OUTFILE"
    sudo tee "$dest" > /dev/null << EOF
Defaults:$CURRENTUSER !logfile, !syslog
$CURRENTUSER ALL=(ALL) NOPASSWD: ALL
EOF
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

# install base
#~ APPLIST=""
#~ sudo pacman -S --noconfirm $APPLIST 2>&1 | tee -a "$OUTFILE"

# remove base
#APPLIST=""
#sudo pacman -Rs --noconfirm $APPLIST 2>&1 | tee -a "$OUTFILE"

# install / remove ============================================================

dest=/usr/bin/geany
if [[ ! -f $dest ]]; then
    echo " *** install softwares" | tee -a "$OUTFILE"
    
    # update
    sudo pacman -Syu 2>&1 | tee -a $OUTFILE
		
	# install base
	APPLIST="geany base-devel git meson ninja"
	sudo pacman -S --noconfirm $APPLIST 2>&1 | tee -a "$OUTFILE"
    
    #~ # install softwares
    APPLIST="hsetroot rofi engrampa p7zip"
    #~ APPLIST+=" mpv numlockx dos2unix cpufrequtils feh"
	sudo pacman -S --noconfirm $APPLIST 2>&1 | tee -a "$OUTFILE"
    
    #~ # install without recommends
    #~ APPLIST="smartmontools"
    #~ sudo apt -y install --no-install-recommends $APPLIST 2>&1 | tee -a $OUTFILE
    
    #~ # uninstall
    APPLIST="matray pamac-gtk tumbler xfce4-power-manager xfce4-screensaver"
    APPLIST+=" blueman bluez mousepad network-manager-applet"
    sudo pacman -Rs --noconfirm $APPLIST 2>&1 | tee -a "$OUTFILE"
    
    #~ # services
    #~ APPLIST="avahi-daemon colord cups cups-browsed rsyslog triggerhappy"
    #~ APPLIST+=" ModemManager wpa_supplicant"
    #~ sudo systemctl stop $APPLIST 2>&1 | tee -a $OUTFILE
    #~ sudo systemctl disable $APPLIST 2>&1 | tee -a $OUTFILE
    #~ APPLIST="raspi-config"
    #~ sudo systemctl disable $APPLIST 2>&1 | tee -a $OUTFILE
    #~ APPLIST="colord"
    #~ sudo systemctl mask $APPLIST 2>&1 | tee -a $OUTFILE

    #~ # user services
    #~ APPLIST="gvfs-afc-volume-monitor.service"
    #~ APPLIST+=" gvfs-goa-volume-monitor.service"
    #~ APPLIST+=" gvfs-gphoto2-volume-monitor.service"
    #~ APPLIST+=" gvfs-mtp-volume-monitor.service"
    #~ systemctl --user stop $APPLIST 2>&1 | tee -a $OUTFILE
    #~ systemctl --user disable $APPLIST 2>&1 | tee -a $OUTFILE
    #~ systemctl --user mask $APPLIST 2>&1 | tee -a $OUTFILE
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

#~ if [ "$(pidof light-locker)" ]; then
    #~ echo " *** light-locker" | tee -a "$OUTFILE"
    #~ sudo apt -y purge light-locker 2>&1 | tee -a "$OUTFILE"
    #~ killall light-locker 2>&1 | tee -a "$OUTFILE"
#~ fi

# xfce4 =======================================================================

dest=/etc/xdg/xfce4
if [[ -d "$dest" ]] && [[ ! -d "$dest".bak ]]; then
    echo " *** copy xdg xfce4" | tee -a "$OUTFILE"
    sudo cp -r "$dest" "$dest".bak 2>&1 | tee -a "$OUTFILE"
    dest=/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-session.xml
    sudo cp "$DEBDIR"/root/xfce4-session.xml "$dest" 2>&1 | tee -a "$OUTFILE"
fi

# startup.sh ------------------------------------------------------------------

dest=/usr/local/bin/startup.sh
if [[ -f "/usr/bin/hsetroot" ]] && [[ ! -f "$dest" ]]; then
    echo " *** startup.sh" | tee -a "$OUTFILE"
    sudo cp "$DEBDIR"/root/startup.sh "$dest" 2>&1 | tee -a "$OUTFILE"
    dest="$HOME"/.config/autostart/startup.desktop
    sudo cp "$DEBDIR"/home/startup.desktop "$dest" 2>&1 | tee -a "$OUTFILE"
fi

# user settings ===============================================================

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

# hide launchers -------------------------------------------------------

#~ desktop_hide()
#~ {
    #~ local filepath="$HOME/.config/autostart/$1.desktop"
    #~ if [[ ! -f "$filepath" ]]; then
        #~ echo " *** hide $1" | tee -a $OUTFILE
        #~ tee "$filepath" > /dev/null << 'EOF'
#~ [Desktop Entry]
#~ Hidden=true
#~ EOF
    #~ fi
#~ }

#~ dest="$HOME/.config/autostart"
#~ if [[ ! -d $dest ]]; then
    #~ echo " *** create autostart directory" | tee -a $OUTFILE
    #~ mkdir -p $dest 2>&1 | tee -a $OUTFILE
#~ fi

#~ desktop_hide "xcompmgr"
#~ desktop_hide "xdg-user-dirs"
#~ desktop_hide "xdg-user-dirs-kde"
#~ desktop_hide "xfce4-notifyd"
#~ desktop_hide "xiccd"

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

