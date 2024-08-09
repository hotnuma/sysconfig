#!/usr/bin/bash

BASEDIR="$(dirname -- "$(readlink -f -- "$0";)")"
DEBDIR="$BASEDIR"
CURRENTUSER="$USER"
OUTFILE="$HOME/install.log"

echo "===============================================================================" | tee -a $OUTFILE
echo " Debian install..." | tee -a $OUTFILE
echo "===============================================================================" | tee -a $OUTFILE

# test if sudo is succesfull ==================================================

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

dest=/etc/sudoers.d/10_custom
if [[ ! -f "$dest" ]]; then
    echo "*** sudoers" | tee -a "$OUTFILE"
    sudo tee "$dest" > /dev/null << EOF
Defaults:$CURRENTUSER !logfile, !syslog
$CURRENTUSER ALL=(ALL) NOPASSWD: ALL
EOF
fi

# install / remove ============================================================

dest=/usr/bin/hsetroot
if [[ ! -f "$dest" ]]; then
    echo "*** install softwares" | tee -a "$OUTFILE"
    
    # install base
    APPLIST="hsetroot geany build-essential pkg-config git meson ninja-build"
    APPLIST+=" clang-format libgtk-3-dev libpcre3-dev"
    APPLIST+=" fonts-dejavu elementary-xfce-icon-theme"
    sudo apt -y install $APPLIST 2>&1 | tee -a "$OUTFILE"

    # install softwares
    APPLIST="rofi htop hardinfo net-tools uchardet curl dos2unix"
    APPLIST+=" gimp evince engrampa p7zip-full"
    APPLIST+=" mpv mkvtoolnix mkvtoolnix-gui mediainfo-gui"
    sudo apt -y install $APPLIST 2>&1 | tee -a "$OUTFILE"
    
    # install without recommends
    APPLIST="smartmontools"
    sudo apt -y install --no-install-recommends $APPLIST 2>&1 | tee -a "$OUTFILE"
    
    # uninstall
    APPLIST="at-spi2-core mousepad synaptic tumbler xfce4-power-manager"
    APPLIST+=" exfalso xfburn xsane zutty"
    sudo apt -y purge $APPLIST 2>&1 | tee -a "$OUTFILE"
    sudo apt -y autoremove 2>&1 | tee -a "$OUTFILE"
    
    # timers
    APPLIST="apt-daily.timer apt-daily-upgrade.timer anacron.timer"
    sudo systemctl stop $APPLIST 2>&1 | tee -a "$OUTFILE"
    sudo systemctl disable $APPLIST 2>&1 | tee -a "$OUTFILE"
    
    # services
    APPLIST="apparmor avahi-daemon cron anacron cups cups-browsed"
    APPLIST+=" bluetooth ModemManager wpa_supplicant"
    sudo systemctl stop $APPLIST 2>&1 | tee -a "$OUTFILE"
    sudo systemctl disable $APPLIST 2>&1 | tee -a "$OUTFILE"
fi
    
# backup files ================================================================

dest=/etc/default/grub
if [[ ! -f ${dest}.bak ]]; then
    echo "*** grub config backup" | tee -a "$OUTFILE"
    sudo cp "$dest" ${dest}.bak 2>&1 | tee -a "$OUTFILE"
fi

# environment -----------------------------------------------------------------

dest=/etc/environment
if [[ ! -f ${dest}.bak ]]; then
    echo "*** environment" | tee -a "$OUTFILE"
    sudo cp "$dest" ${dest}.bak 2>&1 | tee -a "$OUTFILE"
    sudo tee "$dest" > /dev/null << "EOF"
GTK_OVERLAY_SCROLLING=0
NO_AT_BRIDGE=1
EOF
fi

# numlock/autologin -----------------------------------------------------------

dest=/etc/lightdm/lightdm.conf
if [[ ! -f ${dest}.bak ]]; then
    echo "*** numlock on" | tee -a "$OUTFILE"
    xfconf-query -c keyboards -p /Default/Numlock -t bool -s true
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

# xfce4 session ---------------------------------------------------------------

dest=/etc/xdg/xfce4
if [[ -d "$dest" ]] && [[ ! -d "$dest".bak ]]; then
    echo "*** copy xdg xfce4" | tee -a "$OUTFILE"
    sudo cp -r "$dest" "$dest".bak 2>&1 | tee -a "$OUTFILE"
    dest=/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-session.xml
    sudo cp "$DEBDIR"/root/xfce4-session.xml "$dest" 2>&1 | tee -a "$OUTFILE"
fi
    
# startup.sh ------------------------------------------------------------------

dest=/usr/local/bin/startup.sh
if [[ -f "/usr/bin/hsetroot" ]] && [[ ! -f "$dest" ]]; then
    echo "*** startup.sh" | tee -a "$OUTFILE"
    sudo cp "$DEBDIR"/root/startup.sh "$dest" 2>&1 | tee -a "$OUTFILE"
    dest="$HOME"/.config/autostart/startup.desktop
    sudo cp "$DEBDIR"/home/startup.desktop "$dest" 2>&1 | tee -a "$OUTFILE"
fi

# smartd ----------------------------------------------------------------------

if [ "$(pidof smartd)" ]; then
    echo "*** smartd" | tee -a "$OUTFILE"
    sudo systemctl stop smartd 2>&1 | tee -a "$OUTFILE"
    sudo systemctl disable smartd 2>&1 | tee -a "$OUTFILE"
fi

# user settings ===============================================================

dest="$HOME"/.bash_aliases
if [[ ! -f "$dest" ]]; then
    echo "*** aliases" | tee -a "$OUTFILE"
    cp "$DEBDIR"/home/bash_aliases "$dest" 2>&1 | tee -a "$OUTFILE"
    echo "*** appfinder" | tee -a "$OUTFILE"
    xfconf-query -c xfce4-appfinder -np /enable-service -t 'bool' -s 'false'
fi

# config ----------------------------------------------------------------------

dest="$HOME"/config
if [[ ! -L "$dest" ]]; then
    echo "*** config link" | tee -a "$OUTFILE"
    ln -s "$HOME"/.config "$dest" 2>&1 | tee -a "$OUTFILE"
fi

# colorsheme ------------------------------------------------------------------

dest="$HOME"/.local/share/xfce4/terminal/colorschemes
if [[ ! -f "$dest"/custom.theme ]]; then
    echo "*** terminal colors" | tee -a "$OUTFILE"
    mkdir -p "$dest" 2>&1 | tee -a "$OUTFILE"
    cp "$DEBDIR"/home/custom.theme "$dest" 2>&1 | tee -a "$OUTFILE"
fi

# thunar terminal -------------------------------------------------------------

dest="$HOME"/.config/Thunar/uca.xml
if [[ ! -f ${dest}.bak ]] && [[ -f "$dest" ]]; then
    echo "*** thunar terminal" | tee -a "$OUTFILE"
    mv "$dest" ${dest}.bak 2>&1 | tee -a "$OUTFILE"
    cp "$DEBDIR"/home/uca.xml "$dest" 2>&1 | tee -a "$OUTFILE"
fi

# powerctl --------------------------------------------------------------------

dest="$HOME"/.config/autostart/powerctl.desktop
if [[ -f "/usr/local/bin/powerctl" ]] && [[ ! -f "$dest" ]]; then
    echo "*** powerctl" | tee -a "$OUTFILE"
    sudo cp "$DEBDIR"/home/powerctl.desktop "$dest" 2>&1 | tee -a "$OUTFILE"
fi

# resolv.conf -----------------------------------------------------------------

dest=/etc/resolv.conf
if [[ ! -f ${dest}.bak ]]; then
    echo "*** resolv.conf" | tee -a "$OUTFILE"
    sudo cp "$dest" ${dest}.bak 2>&1 | tee -a "$OUTFILE"
    cname="Wired connection 1"
    nmcli con mod "$cname" ipv4.dns "8.8.8.8 8.8.4.4" 2>&1 | tee -a "$OUTFILE"
    nmcli con mod "$cname" ipv4.ignore-auto-dns yes 2>&1 | tee -a "$OUTFILE"
    nmcli con down "$cname" 2>&1 | tee -a "$OUTFILE"
    nmcli con up "$cname" 2>&1 | tee -a "$OUTFILE"
fi

# Hide Launchers --------------------------------------------------------------

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

dest="$HOME"/.local/share/applications/
if [[ ! -d "$dest" ]]; then
    echo "*** create .local/share/applications/" | tee -a "$OUTFILE"
    mkdir -p "$dest" 2>&1 | tee -a "$OUTFILE"
fi

if command -v appinfo &> /dev/null; then
    app_show "gcr-prompter"                 "false" 2>&1 | tee -a "$OUTFILE"
    app_show "gcr-viewer"                   "false" 2>&1 | tee -a "$OUTFILE"
    app_show "system-config-printer"        "false" 2>&1 | tee -a "$OUTFILE"
    app_show "thunar-bulk-rename"           "false" 2>&1 | tee -a "$OUTFILE"
    app_show "xfce4-file-manager"           "false" 2>&1 | tee -a "$OUTFILE"
    app_show "xfce4-mail-reader"            "false" 2>&1 | tee -a "$OUTFILE"
    app_show "xfce4-web-browser"            "false" 2>&1 | tee -a "$OUTFILE"
    app_show "xfce-backdrop-settings"       "false" 2>&1 | tee -a "$OUTFILE"
    #~ app_show "xfce4-appfinder"              "false" 2>&1 | tee -a "$OUTFILE"
    #~ app_show "xfce4-run"                    "false" 2>&1 | tee -a "$OUTFILE"
fi

echo "done" | tee -a $OUTFILE


