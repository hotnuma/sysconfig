#!/usr/bin/bash

basedir="$(dirname -- "$(readlink -f -- "$0";)")"
debdir="$basedir"
builddir="$HOME/DevFiles"
currentuser="$USER"
outfile="$HOME/install.log"
opt_qtcreator=0
opt_yes=0

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

while (($#)); do
    case "$1" in
        qtcreator)
        opt_qtcreator=1
        ;;
        yes)
        opt_yes=1
        ;;
        *)
        ;;
    esac
    shift
done

if [[ $opt_yes != 1 ]]; then
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

echo "===============================================================================" | tee -a $outfile
echo " Debian install..." | tee -a $outfile
echo "===============================================================================" | tee -a $outfile

# sudoers ---------------------------------------------------------------------

dest=/etc/sudoers.d/10_custom
if [[ ! -f "$dest" ]]; then
    echo "*** sudoers" | tee -a "$outfile"
    sudo tee "$dest" > /dev/null << EOF
Defaults:$currentuser !logfile, !syslog
$currentuser ALL=(ALL) NOPASSWD: ALL
EOF
fi

# grub ------------------------------------------------------------------------

dest=/etc/default/grub
if [[ ! -f ${dest}.bak ]]; then
    echo "*** grub config backup" | tee -a "$outfile"
    sudo cp "$dest" ${dest}.bak 2>&1 | tee -a "$outfile"
    sudo tee "$dest" > /dev/null << "EOF"
GRUB_DEFAULT=0
GRUB_TIMEOUT=0
GRUB_DISTRIBUTOR=`lsb_release -i -s 2> /dev/null || echo Debian`
GRUB_CMDLINE_LINUX_DEFAULT="quiet"
GRUB_CMDLINE_LINUX=""
GRUB_BACKGROUND=
EOF
    sudo update-grub 2>&1 | tee -a "$outfile"
fi

# numlock/autologin -----------------------------------------------------------

dest=/etc/lightdm/lightdm.conf
if [[ ! -f ${dest}.bak ]]; then
    echo "*** autologin" | tee -a "$outfile"
    sudo cp "$dest" ${dest}.bak 2>&1 | tee -a "$outfile"
    sudo tee "$dest" > /dev/null << EOF
[Seat:*]
autologin-guest=false
autologin-user=$currentuser
autologin-user-timeout=0
autologin-session=lightdm-xsession
EOF
fi

# disable log messages --------------------------------------------------------

dest=/etc/systemd/system/rtkit-daemon.service.d/
if [[ ! -d ${dest} ]]; then
    echo "*** disable rtkit logs" | tee -a "$outfile"
    sudo mkdir $dest
    dest=/etc/systemd/system/rtkit-daemon.service.d/log.conf
    sudo tee "$dest" > /dev/null << "EOF"
[Service]
LogLevelMax=4
EOF
    sudo systemctl daemon-reload 2>&1 | tee -a "$outfile"
    sudo systemctl restart rtkit-daemon.service 2>&1 | tee -a "$outfile"
fi

# install / remove ============================================================

dest=/usr/bin/hsetroot
if [[ ! -f "$dest" ]]; then
    echo "*** install softwares" | tee -a "$outfile"
    
    # upgrade
    sudo apt update; sudo apt upgrade 2>&1 | tee -a "$outfile"
    
    # create directories
    mkdir "$HOME"/.config/autostart/ 2>/dev/null
    mkdir -p "$HOME"/.local/share/applications/ 2>/dev/null
    mkdir -p "$HOME"/.local/share/xfce4/terminal/colorschemes/ 2>/dev/null
    mkdir "$HOME"/.themes/ 2>/dev/null
    mkdir "$HOME"/Bureau/ 2>/dev/null
    mkdir -p "$HOME"/Downloads/0Supprimer/ 2>/dev/null
    
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
    sudo apt -y install $APPLIST 2>&1 | tee -a "$outfile"

    # install softwares
    APPLIST="curl dos2unix hardinfo htop inxi net-tools p7zip-full"
    APPLIST+=" audacious engrampa geany gimp rofi zathura"
    APPLIST+=" ffmpeg mediainfo-gui mkvtoolnix mkvtoolnix-gui mpv"
    sudo apt -y install $APPLIST 2>&1 | tee -a "$outfile"
    
    # install without recommends
    APPLIST="smartmontools"
    sudo apt -y install --no-install-recommends $APPLIST 2>&1 | tee -a "$outfile"
    
    # uninstall
    APPLIST="at-spi2-core exfalso hv3 light-locker synaptic"
    APPLIST+=" xdg-desktop-portal xsane xterm yt-dlp zutty"
    APPLIST+=" mousepad parole tumbler xfburn xfce4-power-manager"
    sudo apt -y purge $APPLIST 2>&1 | tee -a "$outfile"
    sudo apt -y autoremove 2>&1 | tee -a "$outfile"
    
    # timers
    APPLIST="anacron.timer apt-daily.timer apt-daily-upgrade.timer"
    sudo systemctl stop $APPLIST 2>&1 | tee -a "$outfile"
    sudo systemctl disable $APPLIST 2>&1 | tee -a "$outfile"
    
    # disable services
    APPLIST="anacron apparmor avahi-daemon cron cups cups-browsed"
    APPLIST+=" ModemManager wpa_supplicant"
    sudo systemctl stop $APPLIST 2>&1 | tee -a "$outfile"
    sudo systemctl disable $APPLIST 2>&1 | tee -a "$outfile"
fi

# smartd ----------------------------------------------------------------------

if [ "$(pidof smartd)" ]; then
    echo "*** smartd" | tee -a "$outfile"
    sudo systemctl stop smartd 2>&1 | tee -a "$outfile"
    sudo systemctl disable smartd 2>&1 | tee -a "$outfile"
fi

# install dev packages ========================================================

dest=/usr/include/gumbo.h
if [[ ! -f "$dest" ]]; then
    echo "*** install dev packages" | tee -a "$outfile"
    APPLIST="gettext libxfce4ui-2-dev libxfconf-0-dev xfce4-dev-tools"
    APPLIST+=" libgudev-1.0-dev libgumbo-dev libmediainfo-dev libnotify-dev"
    APPLIST+=" libwnck-3-dev libxmu-dev libxss-dev"
    sudo apt -y install $APPLIST 2>&1 | tee -a "$outfile"
fi

# install QtCreator ===========================================================

dest=/usr/bin/qtcreator
if [[ $opt_qtcreator == 1 ]] && [[ ! -f "$dest" ]]; then
    echo "*** install QtCreator" | tee -a "$outfile"
    APPLIST="qtcreator qt6-base-dev"
    sudo apt -y install $APPLIST 2>&1 | tee -a "$outfile"
fi

# system settings =============================================================

dest=/etc/environment
if [[ ! -f ${dest}.bak ]]; then
    echo "*** environment" | tee -a "$outfile"
    sudo cp "$dest" ${dest}.bak 2>&1 | tee -a "$outfile"
    sudo tee "$dest" > /dev/null << "EOF"
PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
GTK_OVERLAY_SCROLLING=0
NO_AT_BRIDGE=1
EOF
fi

# xfce4 session ---------------------------------------------------------------

dest=/etc/xdg/xfce4
if [[ -d "$dest" ]] && [[ ! -d "$dest".bak ]]; then
    echo "*** copy xdg xfce4" | tee -a "$outfile"
    sudo cp -r "$dest" "$dest".bak 2>&1 | tee -a "$outfile"
    dest=/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-session.xml
    sudo cp "$debdir"/root/xfce4-session.xml "$dest" 2>&1 | tee -a "$outfile"
fi
    
# startup.sh ------------------------------------------------------------------

dest=/usr/local/bin/startup.sh
if [[ -f "/usr/bin/hsetroot" ]] && [[ ! -f "$dest" ]]; then
    echo "*** startup.sh" | tee -a "$outfile"
    sudo cp "$debdir"/root/startup.sh "$dest" 2>&1 | tee -a "$outfile"
    dest="$HOME"/.config/autostart/startup.desktop
    cp "$debdir"/home/startup.desktop "$dest" 2>&1 | tee -a "$outfile"
fi

# user settings ===============================================================

dest="$HOME"/config
if [[ ! -L "$dest" ]]; then
    echo "*** config link" | tee -a "$outfile"
    ln -s "$HOME"/.config "$dest" 2>&1 | tee -a "$outfile"
    
    echo "*** add user to adm group" | tee -a "$outfile"
    sudo usermod -a -G adm $currentuser 2>&1 | tee -a "$outfile"
    
    echo "*** xfce4-panel.xml" | tee -a "$outfile"
    dest="$HOME"/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml
    sudo mv "$dest" ${dest}.bak 2>&1 | tee -a "$outfile"
    sudo cp "$debdir"/home/xfce4-panel.xml "$dest" 2>&1 | tee -a "$outfile"
    
    echo "*** xfconf settings" | tee -a "$outfile"
    xfconf-query -c keyboards -p '/Default/Numlock' -t 'bool' -s 'true' 2>&1 | tee -a "$outfile"
    xfconf-query -c xfwm4 -p '/general/workspace_count' -s 1 2>&1 | tee -a "$outfile"
    xfconf-query -c xfce4-appfinder -np '/enable-service' -t 'bool' -s 'false' 2>&1 | tee -a "$outfile"
    xfconf-query -c xfce4-session -np '/shutdown/ShowHibernate' -t 'bool' -s 'false' 2>&1 | tee -a "$outfile"
    xfconf-query -c xfce4-session -np '/shutdown/ShowHybridSleep' -t 'bool' -s 'false' 2>&1 | tee -a "$outfile"
    xfconf-query -c xfce4-session -np '/shutdown/ShowSuspend' -t 'bool' -s 'false' 2>&1 | tee -a "$outfile"
fi

# powerctl --------------------------------------------------------------------

dest="$HOME"/.config/autostart/powerctl.desktop
if [[ -f "/usr/local/bin/powerctl" ]] && [[ ! -f "$dest" ]]; then
    echo "*** powerctl" | tee -a "$outfile"
    cp "$debdir"/home/powerctl.desktop "$dest" 2>&1 | tee -a "$outfile"
fi

# terminal theme --------------------------------------------------------------

dest="$HOME"/.local/share/xfce4/terminal/colorschemes/custom.theme
if [[ ! -f "$dest" ]]; then
    echo "*** terminal colors" | tee -a "$outfile"
    cp "$debdir"/home/custom.theme "$dest" 2>&1 | tee -a "$outfile"
fi

# thunar uca ------------------------------------------------------------------

dest="$HOME"/.config/Thunar/uca.xml
if [[ ! -f ${dest}.bak ]] && [[ -f "$dest" ]]; then
    echo "*** thunar terminal" | tee -a "$outfile"
    mv "$dest" ${dest}.bak 2>&1 | tee -a "$outfile"
    cp "$debdir"/home/uca.xml "$dest" 2>&1 | tee -a "$outfile"
fi

# Hide Launchers ==============================================================

filemod()
{
    if [[ ! -f "$1" ]]; then
        echo "file ${1} doesn't exist" | tee -a "$outfile"
        return
    fi
    
    filename=$(basename "$1")
    echo "*** hide ${filename}" | tee -a "$outfile"
    dest="$HOME"/.local/share/applications/$filename
    cp "$1" "$HOME"/.local/share/applications/
    sed -i '/^MimeType=/d' "$dest" | tee -a "$outfile"
    echo "NoDisplay=true" >> "$dest"
}

app_hide()
{
    syspath=$(find /usr/local/share/applications/ \
              -name ${1}.desktop -print -quit 2>/dev/null)
    if [[ $syspath != "" ]]; then
        filemod $syspath
        return
    fi
    
    syspath=$(find /usr/share/applications/ \
              -name ${1}.desktop -print -quit 2>/dev/null)
    if [[ $syspath != "" ]]; then
        filemod $syspath
        return
    fi
}

dest="$HOME"/.local/share/applications/fileman.desktop
if [[ ! -f "$dest" ]]; then
    app_hide "fileman"
    app_hide "gcr-prompter"
    app_hide "gcr-viewer"
    app_hide "RealTimeSync"
    app_hide "system-config-printer"
    app_hide "thunar-bulk-rename"
    app_hide "thunar-settings"
    app_hide "thunar-volman-settings"
    app_hide "xfce-backdrop-settings"
    app_hide "xfce4-appfinder"
    app_hide "xfce4-file-manager"
    app_hide "xfce4-mail-reader"
    app_hide "xfce4-run"
    app_hide "xfce4-web-browser"
    echo "*** hide thunar launcher" | tee -a "$outfile"
    dest="$HOME"/.local/share/applications/thunar.desktop
    printf "[Desktop Entry]\nHidden=True\n" > "$dest"
fi

# build from sources ==========================================================

dest="$builddir"
if [[ ! -d "$dest" ]]; then
    echo "*** create build dir" | tee -a "$outfile"
    mkdir "$builddir"
fi
pushd "$builddir" 1>/dev/null

# build from git --------------------------------------------------------------

build_src()
{
    local pack="$1"
    local dest="$2"
    if [[ ! -f "$dest" ]]; then
        echo "*** build ${pack}" | tee -a "$outfile"
        git clone https://github.com/hotnuma/${pack}.git 2>&1 | tee -a "$outfile"
        pushd ${pack} 1>/dev/null
        ./install.sh 2>&1 | tee -a "$outfile"
        popd 1>/dev/null
    fi
}

if [[ ! -f "/usr/local/include/tinyc/cstring.h" ]]; then
    build_src "libtinyc" "/usr/local/include/tinyc/cstring.h"
    build_src "fileman" "/usr/local/bin/fileman"
    build_src "sysquery" "/usr/local/bin/sysquery"
    build_src "systools" "/usr/local/bin/colortest"
    build_src "taskman" "/usr/local/bin/xfce4-taskmanager"
    build_src "applist" "/usr/local/bin/applist"
    build_src "firebook" "/usr/local/bin/firebook"
    build_src "mpvcmd" "/usr/local/bin/mpvcmd"
    build_src "powerctl" "/usr/local/bin/powerctl"
    build_src "volman" "/usr/local/bin/volman"
fi

dest=/usr/local/bin/hoedown
if [[ ! -f "$dest" ]]; then
    echo "*** build hoedown" | tee -a "$outfile"
    git clone https://github.com/hoedown/hoedown.git 2>&1 | tee -a "$outfile"
    pushd hoedown 1>/dev/null
    make && sudo make install 2>&1 | tee -a "$outfile"
    sudo strip /usr/local/bin/hoedown 2>&1 | tee -a "$outfile"
fi

# pop dir ---------------------------------------------------------------------

popd 1>/dev/null
echo "done" | tee -a $outfile


