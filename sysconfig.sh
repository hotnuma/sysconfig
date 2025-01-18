#!/usr/bin/bash

BASEDIR="$(dirname -- "$(readlink -f -- "$0";)")"
DEBDIR="$BASEDIR"
BUILDDIR="$HOME/DevFiles"
CURRENTUSER="$USER"
OUTFILE="$HOME/install.log"
QTCREATOR=0
YES=0

# tests =======================================================================

if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    DISTID=$ID
    DISTVER=$VERSION_ID
fi

if [ $XDG_CURRENT_DESKTOP != "XFCE" ]; then
    echo "*** XFCE was not detected"
    echo "abort..."
    exit 1
fi

while [[ $# > 0 ]]; do
    arg="$1"
    case $arg in
        qtcreator)
        QTCREATOR=1
        shift
        ;;
        yes)
        YES=1
        shift
        ;;
        *)
        shift
        ;;
    esac
done

if [[ $YES != 1 ]]; then
    # don't run a scipt without nowing what it does :-P
    echo "*** missing parameter"
    echo "abort..."
    exit 1
fi

# system settings =============================================================

if [[ "$EUID" = 0 ]]; then
    echo "*** must not be run as root"
    echo "abort..."
    exit 1
else
    sudo -k # make sure to ask for password on next sudo
    if ! sudo true; then
        echo "*** sudo failed"
        echo "abort..."
        exit 1
    fi
fi

# start =======================================================================

echo "===============================================================================" | tee -a $OUTFILE
echo " Debian install..." | tee -a $OUTFILE
echo "===============================================================================" | tee -a $OUTFILE

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
    sudo tee "$dest" > /dev/null << "EOF"
GRUB_DEFAULT=0
GRUB_TIMEOUT=0
GRUB_DISTRIBUTOR=`lsb_release -i -s 2> /dev/null || echo Debian`
GRUB_CMDLINE_LINUX_DEFAULT="quiet"
GRUB_CMDLINE_LINUX=""
GRUB_BACKGROUND=
EOF
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

# disable log messages --------------------------------------------------------

dest=/etc/systemd/system/rtkit-daemon.service.d/
if [[ ! -d ${dest} ]]; then
    echo "*** disable rtkit logs" | tee -a "$OUTFILE"
    sudo mkdir $dest
    dest=/etc/systemd/system/rtkit-daemon.service.d/log.conf
    sudo tee "$dest" > /dev/null << "EOF"
[Service]
LogLevelMax=4
EOF
    sudo systemctl daemon-reload 2>&1 | tee -a "$OUTFILE"
    sudo systemctl restart rtkit-daemon.service 2>&1 | tee -a "$OUTFILE"
fi

# install / remove ============================================================

dest=/usr/bin/hsetroot
if [[ ! -f "$dest" ]]; then
    echo "*** install softwares" | tee -a "$OUTFILE"
    
    # upgrade
    sudo apt update; sudo apt upgrade 2>&1 | tee -a "$OUTFILE"
    
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
    APPLIST="dmz-cursor-theme elementary-xfce-icon-theme fonts-dejavu hsetroot"
    APPLIST+=" build-essential clang-format git meson ninja-build pkg-config python3-pip"
    APPLIST+=" libglib2.0-doc libgtk-3-dev libgtk-3-doc gtk-3-examples libpcre3-dev"
    sudo apt -y install $APPLIST 2>&1 | tee -a "$OUTFILE"

    # install softwares
    APPLIST="curl dos2unix hardinfo htop inxi net-tools p7zip-full"
    APPLIST+=" audacious engrampa feh geany gimp rofi zathura"
    APPLIST+=" ffmpeg mediainfo-gui mkvtoolnix mkvtoolnix-gui mpv"
    sudo apt -y install $APPLIST 2>&1 | tee -a "$OUTFILE"
    
    # install without recommends
    APPLIST="smartmontools"
    sudo apt -y install --no-install-recommends $APPLIST 2>&1 | tee -a "$OUTFILE"
    
    # uninstall
    APPLIST="at-spi2-core exfalso hv3 light-locker synaptic"
    APPLIST+=" xdg-desktop-portal xsane xterm yt-dlp zutty"
    APPLIST+=" mousepad parole tumbler xfburn xfce4-power-manager"
    sudo apt -y purge $APPLIST 2>&1 | tee -a "$OUTFILE"
    sudo apt -y autoremove 2>&1 | tee -a "$OUTFILE"
    
    # timers
    APPLIST="anacron.timer apt-daily.timer apt-daily-upgrade.timer"
    sudo systemctl stop $APPLIST 2>&1 | tee -a "$OUTFILE"
    sudo systemctl disable $APPLIST 2>&1 | tee -a "$OUTFILE"
    
    # services
    APPLIST="anacron apparmor avahi-daemon cron cups cups-browsed"
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
    echo "*** install dev packages" | tee -a "$OUTFILE"
    APPLIST="gettext libxfce4ui-2-dev libxfconf-0-dev xfce4-dev-tools"
    APPLIST+=" libgudev-1.0-dev libgumbo-dev libmediainfo-dev libnotify-dev"
    APPLIST+=" libwnck-3-dev libxmu-dev libxss-dev"
    sudo apt -y install $APPLIST 2>&1 | tee -a "$OUTFILE"
fi

# install QtCreator ===========================================================

dest=/usr/bin/qtcreator
if [[ $QTCREATOR == 1 ]] && [[ ! -f "$dest" ]]; then
    echo "*** install QtCreator" | tee -a "$OUTFILE"
    APPLIST="qtcreator qt6-base-dev"
    # APPLIST+=" qtchooser qt6-tools-dev qmake6"
    sudo apt -y install $APPLIST 2>&1 | tee -a "$OUTFILE"
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
    
    echo "*** add user to adm group" | tee -a "$OUTFILE"
    sudo usermod -a -G adm $CURRENTUSER 2>&1 | tee -a "$OUTFILE"
    
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

# terminal theme --------------------------------------------------------------

dest="$HOME"/.local/share/xfce4/terminal/colorschemes/custom.theme
if [[ ! -f "$dest" ]]; then
    echo "*** terminal colors" | tee -a "$OUTFILE"
    cp "$DEBDIR"/home/custom.theme "$dest" 2>&1 | tee -a "$OUTFILE"
fi

# thunar uca ------------------------------------------------------------------

dest="$HOME"/.config/Thunar/uca.xml
if [[ ! -f ${dest}.bak ]] && [[ -f "$dest" ]]; then
    echo "*** thunar terminal" | tee -a "$OUTFILE"
    mv "$dest" ${dest}.bak 2>&1 | tee -a "$OUTFILE"
    cp "$DEBDIR"/home/uca.xml "$dest" 2>&1 | tee -a "$OUTFILE"
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
    app_show "fileman"                      "false" 2>&1 | tee -a "$OUTFILE"
    app_show "gcr-prompter"                 "false" 2>&1 | tee -a "$OUTFILE"
    app_show "gcr-viewer"                   "false" 2>&1 | tee -a "$OUTFILE"
    app_show "RealTimeSync"                 "false" 2>&1 | tee -a "$OUTFILE"
    app_show "system-config-printer"        "false" 2>&1 | tee -a "$OUTFILE"
    app_show "thunar-bulk-rename"           "false" 2>&1 | tee -a "$OUTFILE"
    app_show "thunar-settings"              "false" 2>&1 | tee -a "$OUTFILE"
    app_show "thunar-volman-settings"       "false" 2>&1 | tee -a "$OUTFILE"
    app_show "xfce-backdrop-settings"       "false" 2>&1 | tee -a "$OUTFILE"
    app_show "xfce4-appfinder"              "false" 2>&1 | tee -a "$OUTFILE"
    app_show "xfce4-file-manager"           "false" 2>&1 | tee -a "$OUTFILE"
    app_show "xfce4-mail-reader"            "false" 2>&1 | tee -a "$OUTFILE"
    app_show "xfce4-run"                    "false" 2>&1 | tee -a "$OUTFILE"
    app_show "xfce4-web-browser"            "false" 2>&1 | tee -a "$OUTFILE"
fi

dest="$HOME"/.local/share/applications/thunar.desktop
if [[ ! -f "$dest" ]]; then
    echo "*** hide thunar launcher" | tee -a "$OUTFILE"
    printf "[Desktop Entry]\nHidden=True\n" > "$dest"
fi

# build from sources ==========================================================

dest="$BUILDDIR"
if [[ ! -d "$dest" ]]; then
    echo "*** create build dir" | tee -a "$OUTFILE"
    mkdir "$BUILDDIR"
fi
pushd "$BUILDDIR" 1>/dev/null

# build from git --------------------------------------------------------------

build_src()
{
    local pack="$1"
    local dest="$2"
    if [[ ! -f "$dest" ]]; then
        echo "*** build ${pack}" | tee -a "$OUTFILE"
        git clone https://github.com/hotnuma/${pack}.git 2>&1 | tee -a "$OUTFILE"
        pushd ${pack} 1>/dev/null
        ./install.sh 2>&1 | tee -a "$OUTFILE"
        popd 1>/dev/null
    fi
}

if [[ ! -f "/usr/local/include/tinyc/cstring.h" ]]; then
    build_src "libtinyc" "/usr/local/include/tinyc/cstring.h"
    build_src "fileman" "/usr/local/bin/fileman"
    build_src "systools" "/usr/local/bin/colortest"
    build_src "taskman" "/usr/local/bin/xfce4-taskmanager"
fi

if [[ ! -f "/usr/local/bin/mpvcmd" ]]; then
    build_src "mpvcmd" "/usr/local/bin/mpvcmd"
    build_src "powerctl" "/usr/local/bin/powerctl"
    build_src "sysquery" "/usr/local/bin/sysquery"
    build_src "volman" "/usr/local/bin/volman"
fi

if [[ ! -f "/usr/local/bin/appinfo" ]]; then
    build_src "appinfo" "/usr/local/bin/appinfo"
    build_src "applist" "/usr/local/bin/applist"
    build_src "firebook" "/usr/local/bin/firebook"
    build_src "sfind" "/usr/local/bin/sfind"
fi

dest=/usr/local/bin/hoedown
if [[ ! -f "$dest" ]]; then
    echo "*** build hoedown" | tee -a "$OUTFILE"
    git clone https://github.com/hoedown/hoedown.git 2>&1 | tee -a "$OUTFILE"
    pushd hoedown 1>/dev/null
    make && sudo make install 2>&1 | tee -a "$OUTFILE"
    sudo strip /usr/local/bin/hoedown 2>&1 | tee -a "$OUTFILE"
fi

# pop dir ---------------------------------------------------------------------

popd 1>/dev/null
echo "done" | tee -a $OUTFILE


