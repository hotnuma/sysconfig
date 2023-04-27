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
    echo "*** sudoers" 2>&1 | tee -a "$OUTFILE"
    sudo tee "$dest" > /dev/null << EOF
Defaults:$CURRENTUSER !logfile, !syslog
$CURRENTUSER ALL=(ALL) NOPASSWD: ALL
EOF
fi

# backups ---------------------------------------------------------------------

dest=/etc/default/grub
if [[ ! -f ${dest}.bak ]]; then
    echo "*** grub config backup" 2>&1 | tee -a "$OUTFILE"
    sudo cp "$dest" ${dest}.bak 2>&1 | tee -a "$OUTFILE"
fi

# aliases ---------------------------------------------------------------------

dest="$HOME"/.bash_aliases
if [[ ! -f "$dest" ]]; then
    echo "*** aliases" 2>&1 | tee -a "$OUTFILE"
    sudo cp "$BASEDIR"/home/bash_aliases "$dest" 2>&1 | tee -a "$OUTFILE"
fi

# environment -----------------------------------------------------------------

dest=/etc/environment
if [[ ! -f ${dest}.bak ]]; then
    echo "*** environment" 2>&1 | tee -a "$OUTFILE"
    sudo cp "$dest" ${dest}.bak 2>&1 | tee -a "$OUTFILE"
    sudo cp "$BASEDIR"/root/environment "$dest" 2>&1 | tee -a "$OUTFILE"
fi

# autostart -------------------------------------------------------------------

dest=/usr/local/bin/startup.sh
if [[ ! -f "$dest" ]]; then
    echo "*** autostart" 2>&1 | tee -a "$OUTFILE"
    sudo cp "$BASEDIR"/root/startup.sh "$dest" 2>&1 | tee -a "$OUTFILE"
    cp -r "$BASEDIR"/home/config/autostart/* "$HOME"/.config/autostart/ 2>&1 | tee -a "$OUTFILE"
fi

# autologin -------------------------------------------------------------------

dest=/etc/lightdm/lightdm.conf
if [[ ! -f ${dest}.bak ]]; then
    echo "*** autologin" 2>&1 | tee -a "$OUTFILE"
    sudo cp "$dest" ${dest}.bak 2>&1 | tee -a "$OUTFILE"
    sudo cp "$BASEDIR"/root/lightdm.conf "$dest" 2>&1 | tee -a "$OUTFILE"
fi

# startxfce4 ------------------------------------------------------------------

dest=/usr/bin/startxfce4
if [[ ! -f ${dest}.bak ]]; then
    echo "*** startxfce4" 2>&1 | tee -a "$OUTFILE"
    sudo mv "$dest" ${dest}.bak 2>&1 | tee -a "$OUTFILE"
    sudo cp "$BASEDIR"/root/startxfce4 "$dest" 2>&1 | tee -a "$OUTFILE"
fi

# install / remove ------------------------------------------------------------

dest=/usr/bin/htop
if [[ ! -f "$dest" ]]; then
    echo "*** install softwares" 2>&1 | tee -a "$OUTFILE"
    
    # uninstall snaps
    sudo rm -rf /var/cache/snapd/ 2>&1 | tee -a "$OUTFILE"
    sudo apt -y purge snapd gnome-software-plugin-snap 2>&1 | tee -a "$OUTFILE"
    rm -rf ~/snap 2>&1 | tee -a "$OUTFILE"
    
    # install base
    APPLIST="htop hsetroot geany hardinfo lm-sensors net-tools xfce4-taskmanager"
    APPLIST+=" p7zip-full engrampa mpv mkvtoolnix mkvtoolnix-gui mediainfo-gui"
    APPLIST+=" gimp evince rofi uchardet"
    APPLIST+=" build-essential git meson ninja-build dos2unix"
    sudo apt -y install $APPLIST 2>&1 | tee -a "$OUTFILE"
    
    # libsecret-tools
    
    APPLIST="--no-install-recommends smartmontools"
    sudo apt -y install $APPLIST 2>&1 | tee -a "$OUTFILE"
    
    # uninstall
    APPLIST="thunderbird synaptic xfce4-power-manager xfce4-screensaver tumbler"
    APPLIST+=" at-spi2-core fwupd thermald geoclue-2.0 printer-driver-foo2zjs-common"
    sudo apt -y purge $APPLIST 2>&1 | tee -a "$OUTFILE"
    sudo apt -y autoremove 2>&1 | tee -a "$OUTFILE"
    
    # timers
    APPLIST="anacron.timer motd-news.timer"
    APPLIST+=" ua-timer.timer ua-license-check.timer ua-license-check.path"
    APPLIST+=" apt-daily.timer apt-daily-upgrade.timer man-db.timer"
    sudo systemctl stop $APPLIST 2>&1 | tee -a "$OUTFILE"
    sudo systemctl disable $APPLIST 2>&1 | tee -a "$OUTFILE"
    
    # services
    APPLIST="apparmor avahi-daemon anacron cron cups cups-browsed"
    APPLIST+=" bluetooth wpa_supplicant unattended-upgrades"
    APPLIST+=" kerneloops rsyslog"
    sudo systemctl stop $APPLIST 2>&1 | tee -a "$OUTFILE"
    sudo systemctl disable $APPLIST 2>&1 | tee -a "$OUTFILE"
fi

# install dev apps ------------------------------------------------------------

dest=/usr/bin/qtcreator
if [[ ! -f "$dest" ]]; then
    echo "*** install dev softwares" 2>&1 | tee -a "$OUTFILE"
    
    # install dev
    APPLIST="qtcreator qtchooser qtbase5-dev qt5-qmake qtbase5-dev-tools"
    APPLIST+=" libgtk-3-dev libgtk-3-doc gtk-3-examples libglib2.0-doc"
    APPLIST+=" gettext clang-format libmediainfo-dev libprocps-dev"
    sudo apt -y install $APPLIST 2>&1 | tee -a "$OUTFILE"
fi

# Hide Launchers --------------------------------------------------------------

dest="$HOME"/.local/share/applications/
if [[ ! -d "$dest" ]]; then
    echo "*** create .local/share/applications/" 2>&1 | tee -a "$OUTFILE"
    mkdir -p "$dest" 2>&1 | tee -a "$OUTFILE"
fi

if command -v appinfo &> /dev/null; then
    app_show "debian-uxterm"                "false" 2>&1 | tee -a "$OUTFILE"
    app_show "debian-xterm"                 "false" 2>&1 | tee -a "$OUTFILE"
    app_show "gcr-prompter"                 "false" 2>&1 | tee -a "$OUTFILE"
    app_show "gcr-viewer"                   "false" 2>&1 | tee -a "$OUTFILE"
    app_show "gtk3-demo"                    "true"  2>&1 | tee -a "$OUTFILE"
    app_show "org.gnome.Evince-previewer"   "false" 2>&1 | tee -a "$OUTFILE"
    app_show "RealTimeSync"                 "false" 2>&1 | tee -a "$OUTFILE"
    app_show "xfce4-appfinder"              "false" 2>&1 | tee -a "$OUTFILE"
    app_show "xfce4-file-manager"           "false" 2>&1 | tee -a "$OUTFILE"
    app_show "xfce4-mail-reader"            "false" 2>&1 | tee -a "$OUTFILE"
    app_show "xfce4-run"                    "false" 2>&1 | tee -a "$OUTFILE"
    app_show "xfce4-web-browser"            "false" 2>&1 | tee -a "$OUTFILE"
    app_show "xfce-backdrop-settings"       "false" 2>&1 | tee -a "$OUTFILE"
fi


