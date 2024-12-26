#!/usr/bin/bash

BASEDIR="$(dirname -- "$(readlink -f -- "$0";)")"
DEBDIR="$BASEDIR"
CURRENTUSER="$USER"
OUTFILE="$HOME/install.log"

echo "===============================================================================" | tee -a $OUTFILE
echo " Debian install..." | tee -a $OUTFILE
echo "===============================================================================" | tee -a $OUTFILE

# system settings =============================================================

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

# grub ------------------------------------------------------------------------

dest=/etc/default/grub
if [[ ! -f ${dest}.bak ]]; then
    echo "*** grub config backup" | tee -a "$OUTFILE"
    sudo cp "$dest" ${dest}.bak 2>&1 | tee -a "$OUTFILE"
    sudo sed -e 's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=0/' -i "$dest" 2>&1 | tee -a "$OUTFILE"
    sudo update-grub 2>&1 | tee -a "$OUTFILE"
fi

# numlock/autologin -----------------------------------------------------------

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

# install / remove ============================================================

dest=/usr/bin/hsetroot
if [[ ! -f "$dest" ]]; then
    echo "*** install softwares" | tee -a "$OUTFILE"
    
    # upgrade
    sudo apt update; sudo apt upgrade
    
    # create directories
    mkdir "$HOME"/.config/autostart/ 2>/dev/null
    mkdir -p "$HOME"/.local/share/applications/ 2>/dev/null
    mkdir -p "$HOME"/.local/share/xfce4/terminal/colorschemes/ 2>/dev/null
    mkdir "$HOME"/.themes/ 2>/dev/null
    mkdir "$HOME"/Bureau/ 2>/dev/null
    mkdir -p "$HOME"/Downloads/0Supprimer/ 2>/dev/null
    
    # set xfce settings
    echo "*** xfconf settings" | tee -a "$OUTFILE"
    xfconf-query -c keyboards -p /Default/Numlock -t bool -s true 2>&1 | tee -a "$OUTFILE"
    xfconf-query -c xfwm4 -p /general/workspace_count -s 1 2>&1 | tee -a "$OUTFILE"
    
    # disable autostart programs
    printf "[Desktop Entry]\nHidden=True\n" > "$HOME"/.config/autostart/nm-applet.desktop
    printf "[Desktop Entry]\nHidden=True\n" > "$HOME"/.config/autostart/print-applet.desktop
    printf "[Desktop Entry]\nHidden=True\n" > "$HOME"/.config/autostart/xdg-user-dirs.desktop
    printf "[Desktop Entry]\nHidden=True\n" > "$HOME"/.config/autostart/xfce4-clipman-plugin-autostart.desktop
    printf "[Desktop Entry]\nHidden=True\n" > "$HOME"/.config/autostart/xiccd.desktop
    printf "[Desktop Entry]\nHidden=True\n" > "$HOME"/.config/autostart/xscreensaver.desktop
    
    # install base
    APPLIST="hsetroot inxi dmz-cursor-theme fonts-dejavu elementary-xfce-icon-theme"
    APPLIST+=" geany git build-essential pkg-config meson ninja-build clang-format"
    APPLIST+=" libgtk-3-dev libpcre3-dev"
    sudo apt -y install $APPLIST 2>&1 | tee -a "$OUTFILE"

    # install softwares
    APPLIST="rofi htop hardinfo net-tools uchardet curl dos2unix"
    APPLIST+=" gimp evince engrampa p7zip-full"
    APPLIST+=" mpv mkvtoolnix mkvtoolnix-gui mediainfo-gui zathura"
    sudo apt -y install $APPLIST 2>&1 | tee -a "$OUTFILE"
    
    # install without recommends
    APPLIST="smartmontools"
    sudo apt -y install --no-install-recommends $APPLIST 2>&1 | tee -a "$OUTFILE"
    
    # uninstall
    APPLIST="at-spi2-core exfalso light-locker mousepad synaptic tumbler"
    APPLIST+=" xdg-desktop-portal xfburn xfce4-power-manager xsane"
    sudo apt -y purge $APPLIST 2>&1 | tee -a "$OUTFILE"
    sudo apt -y autoremove 2>&1 | tee -a "$OUTFILE"
    
    # timers
    APPLIST="apt-daily.timer apt-daily-upgrade.timer anacron.timer"
    sudo systemctl stop $APPLIST 2>&1 | tee -a "$OUTFILE"
    sudo systemctl disable $APPLIST 2>&1 | tee -a "$OUTFILE"
    
    # services
    APPLIST="apparmor avahi-daemon cron anacron cups cups-browsed"
    APPLIST+=" ModemManager wpa_supplicant"
    sudo systemctl stop $APPLIST 2>&1 | tee -a "$OUTFILE"
    sudo systemctl disable $APPLIST 2>&1 | tee -a "$OUTFILE"
fi

# smartd ----------------------------------------------------------------------

if [ "$(pidof smartd)" ]; then
    echo "*** smartd" | tee -a "$OUTFILE"
    sudo systemctl stop smartd 2>&1 | tee -a "$OUTFILE"
    sudo systemctl disable smartd 2>&1 | tee -a "$OUTFILE"
fi

# install dev packages ========================================================

dest=/usr/include/gumbo.h
if [[ ! -f "$dest" ]]; then
    echo " *** install dev packages"
    APPLIST="gettext xfce4-dev-tools libxfconf-0-dev libxfce4ui-2-dev"
    APPLIST+=" libgudev-1.0-dev libgumbo-dev libnotify-dev libwnck-3-dev"
    APPLIST+=" libxss-dev libxmu-dev"
    sudo apt -y install $APPLIST
fi

# system settings =============================================================

dest=/etc/environment
if [[ ! -f ${dest}.bak ]]; then
    echo "*** environment" | tee -a "$OUTFILE"
    sudo cp "$dest" ${dest}.bak 2>&1 | tee -a "$OUTFILE"
    sudo tee "$dest" > /dev/null << "EOF"
PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
GTK_OVERLAY_SCROLLING=0
NO_AT_BRIDGE=1
EOF
    sudo usermod -a -G adm $CURRENTUSER
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
    cp "$DEBDIR"/home/startup.desktop "$dest" 2>&1 | tee -a "$OUTFILE"
fi

# user settings ===============================================================

dest="$HOME"/config
if [[ ! -L "$dest" ]]; then
    echo "*** config link" | tee -a "$OUTFILE"
    ln -s "$HOME"/.config "$dest" 2>&1 | tee -a "$OUTFILE"
    echo "*** xfce4-panel.xml" | tee -a "$OUTFILE"
    dest="$HOME"/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml
    sudo mv "$dest" ${dest}.bak 2>&1 | tee -a "$OUTFILE"
    sudo cp "$DEBDIR"/home/xfce4-panel.xml "$dest" 2>&1 | tee -a "$OUTFILE"
    echo "*** appfinder" | tee -a "$OUTFILE"
    xfconf-query -c xfce4-appfinder -np /enable-service -t 'bool' -s 'false'
fi

# aliases ---------------------------------------------------------------------

dest="$HOME"/.bash_aliases
if [[ ! -f "$dest" ]]; then
    echo "*** aliases" | tee -a "$OUTFILE"
    cp "$DEBDIR"/home/bash_aliases "$dest" 2>&1 | tee -a "$OUTFILE"
fi

# powerctl --------------------------------------------------------------------

dest="$HOME"/.config/autostart/powerctl.desktop
if [[ -f "/usr/local/bin/powerctl" ]] && [[ ! -f "$dest" ]]; then
    echo "*** powerctl" | tee -a "$OUTFILE"
    sudo cp "$DEBDIR"/home/powerctl.desktop "$dest" 2>&1 | tee -a "$OUTFILE"
fi

# thunar uca ------------------------------------------------------------------

dest="$HOME"/.config/Thunar/uca.xml
if [[ ! -f ${dest}.bak ]] && [[ -f "$dest" ]]; then
    echo "*** thunar terminal" | tee -a "$OUTFILE"
    mv "$dest" ${dest}.bak 2>&1 | tee -a "$OUTFILE"
    cp "$DEBDIR"/home/uca.xml "$dest" 2>&1 | tee -a "$OUTFILE"
fi

# terminal theme --------------------------------------------------------------

dest="$HOME"/.local/share/xfce4/terminal/colorschemes/custom.theme
if [[ ! -f "$dest" ]]; then
    echo "*** terminal colors" | tee -a "$OUTFILE"
    cp "$DEBDIR"/home/custom.theme "$dest" 2>&1 | tee -a "$OUTFILE"
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

if command -v appinfo &> /dev/null; then
    app_show "gcr-prompter"                 "false" 2>&1 | tee -a "$OUTFILE"
    app_show "gcr-viewer"                   "false" 2>&1 | tee -a "$OUTFILE"
    app_show "system-config-printer"        "false" 2>&1 | tee -a "$OUTFILE"
    app_show "thunar-bulk-rename"           "false" 2>&1 | tee -a "$OUTFILE"
    app_show "xfce-backdrop-settings"       "false" 2>&1 | tee -a "$OUTFILE"
    app_show "xfce4-appfinder"              "false" 2>&1 | tee -a "$OUTFILE"
    app_show "xfce4-file-manager"           "false" 2>&1 | tee -a "$OUTFILE"
    app_show "xfce4-mail-reader"            "false" 2>&1 | tee -a "$OUTFILE"
    app_show "xfce4-run"                    "false" 2>&1 | tee -a "$OUTFILE"
    app_show "xfce4-web-browser"            "false" 2>&1 | tee -a "$OUTFILE"
fi

echo "done" | tee -a $OUTFILE


