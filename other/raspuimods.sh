#!/usr/bin/bash

BASEDIR="$(dirname -- "$(readlink -f -- "$0";)")"
DEBDIR="$BASEDIR/../debian"
CURRENTUSER="$USER"
OUTFILE="$HOME/install.log"

echo "===============================================================================" | tee -a $OUTFILE
echo " Raspi install..." | tee -a $OUTFILE
echo "===============================================================================" | tee -a $OUTFILE

#~ Depends: dconf-gsettings-backend | gsettings-backend, lxpanel, pcmanfm, openbox, xserver-xorg, x11-xserver-utils, policykit-1, lightdm, raspberrypi-sys-mods (>= 20210706), zenity, libglib2.0-bin, desktop-file-utils, lxsession, adduser, mutter, xdg-user-dirs, raspi-config (>= 20220301)
#~ Recommends: xserver-xorg-video-fbturbo, fonts-piboto (>= 1.1), pipanel, lxinput, pi-greeter, rpd-plym-splash, rpd-wallpaper, pishutdown, scrot, gtk2-engines-pixbuf, gtk2-engines-clearlookspix, gnome-icon-theme, pixflat-icons, lxplug-volumepulse, lxplug-network, lxplug-bluetooth, lxplug-ejecter, lxplug-ptbatt, rc-gui (>= 1.18), gtk2-engines-pixflat, lxplug-cputemp, lxplug-magnifier, rp-bookshelf, agnostics, gui-pkinst, cups, system-config-printer, pi-printer-support, lxplug-updater, lxplug-netman, lxplug-menu

# purge libcamera-tools

dest=/usr/bin/always
if [[ ! -f $dest ]]; then
    echo " *** install softwares" | tee -a "$OUTFILE"
    
    # update
    #sudo apt update && sudo apt full-upgrade 2>&1 | tee -a $OUTFILE
    
    # install depends
    APPLIST="dconf-gsettings-backend lxpanel pcmanfm openbox"
    APPLIST+=" xserver-xorg x11-xserver-utils policykit-1 lightdm"
    APPLIST+=" raspberrypi-sys-mods zenity libglib2.0-bin desktop-file-utils"
    APPLIST+=" lxsession adduser mutter xdg-user-dirs raspi-config"
    sudo apt -y install $APPLIST 2>&1 | tee -a "$OUTFILE"
fi


