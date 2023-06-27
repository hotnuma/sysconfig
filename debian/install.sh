#!/usr/bin/bash

BASEDIR="$(dirname -- "$(readlink -f -- "$0";)")"
OUTFILE="$HOME/install.log"
rm -f "$OUTFILE"

# Functions -------------------------------------------------------------------

app_show()
{
    userpath=$(appinfo -u "$1")
    if [[ $userpath != "" ]]; then
        return
    fi
    
    syspath=$(appinfo -f "$1")
    if [[ $syspath == "" ]]; then
        return
    fi
    
    if [[ $2 == "true" ]]; then
        appinfo -s "$1" 2>&1 | tee -a "$OUTFILE"
    else
        appinfo -h "$1" 2>&1 | tee -a "$OUTFILE"
    fi
}

# test if sudo is succesfull --------------------------------------------------

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

# sudoers ---------------------------------------------------------------------

CURRENTUSER=$USER
dest=/etc/sudoers.d/10_custom
if [[ ! -f "$dest" ]]; then
    echo "*** sudoers" | tee -a "$OUTFILE"
    sudo tee "$dest" > /dev/null << EOF
Defaults:$CURRENTUSER !logfile, !syslog
$CURRENTUSER ALL=(ALL) NOPASSWD: ALL
EOF
fi

# autologin -------------------------------------------------------------------

dest=/etc/lightdm/lightdm.conf
if [[ ! -f ${dest}.bak ]]; then
    echo "*** autologin" | tee -a "$OUTFILE"
    sudo cp "$dest" ${dest}.bak 2>&1 | tee -a "$OUTFILE"
    sudo tee "$dest" > /dev/null << EOF
[Seat:*]
autologin-guest=false
autologin-user=$CURRENTUSER
autologin-user-timeout=0
autologin-session=lightdm-xsession
EOF
fi

# install / remove ------------------------------------------------------------

dest=/usr/bin/geany
if [[ ! -f "$dest" ]]; then
    echo "*** install softwares" | tee -a "$OUTFILE"
    
    # install base
    APPLIST="geany build-essential git meson ninja-build clang-format"
    APPLIST+=" rofi"
    sudo apt -y install $APPLIST 2>&1 | tee -a "$OUTFILE"

    # install softwares
    APPLIST="htop hardinfo net-tools hsetroot uchardet"
    APPLIST+=" curl dos2unix"
    APPLIST+=" gimp evince engrampa p7zip-full"
    APPLIST+=" mpv mkvtoolnix mkvtoolnix-gui mediainfo-gui"
    sudo apt -y install $APPLIST 2>&1 | tee -a "$OUTFILE"
    
    # install without recommends
    APPLIST="--no-install-recommends smartmontools"
    sudo apt -y install $APPLIST 2>&1 | tee -a "$OUTFILE"
    
    # uninstall
    APPLIST="synaptic mousepad xfce4-power-manager tumbler at-spi2-core"
    sudo apt -y purge $APPLIST 2>&1 | tee -a "$OUTFILE"
    sudo apt -y autoremove 2>&1 | tee -a "$OUTFILE"
    
    # timers
    APPLIST="apt-daily.timer apt-daily-upgrade.timer anacron.timer"
    sudo systemctl stop $APPLIST 2>&1 | tee -a "$OUTFILE"
    sudo systemctl disable $APPLIST 2>&1 | tee -a "$OUTFILE"
    
    # services
    APPLIST="apparmor avahi-daemon cron anacron cups cups-browsed"
    APPLIST+=" bluetooth wpa_supplicant rsyslog"
    sudo systemctl stop $APPLIST 2>&1 | tee -a "$OUTFILE"
    sudo systemctl disable $APPLIST 2>&1 | tee -a "$OUTFILE"
fi


