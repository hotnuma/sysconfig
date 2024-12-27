#!/usr/bin/bash

BASEDIR="$(dirname -- "$(readlink -f -- "$0";)")"
BUILDDIR="$HOME/DevFiles"

# install ---------------------------------------------------------------------

if [[ -f /boot/config.txt ]]; then
    DISTID="raspios"
    DISTVER="11"
elif [[ -f /etc/os-release ]]; then
    . /etc/os-release
    DISTID=$ID
    DISTVER=$VERSION_ID
fi

case $DISTID in
debian)
    $BASEDIR/debian/config.sh
    ;;
raspios)
    $BASEDIR/raspios/config.sh
    ;;
ubuntu)
    $BASEDIR/xubuntu/config.sh
    exit 0
    ;;
*)
    echo "Unknown system"
    exit 1
    ;;
esac

# build directory -------------------------------------------------------------

dest="$BUILDDIR"
if [[ ! -d "$dest" ]]; then
    echo " *** create build dir"
    mkdir "$BUILDDIR"
fi
pushd "$BUILDDIR" 1>/dev/null

# build from git --------------------------------------------------------------

build_src()
{
    local pack="$1"
    local dest="$2"
    if [[ ! -f "$dest" ]]; then
        echo " *** ${pack}"
        git clone https://github.com/hotnuma/${pack}.git
        pushd ${pack} 1>/dev/null
        ./install.sh
        popd 1>/dev/null
    fi
}

if [[ ! -f "/usr/local/include/tinyc/cstring.h" ]]; then
    build_src "libtinyc" "/usr/local/include/tinyc/cstring.h"
    build_src "fileman" "/usr/local/bin/fileman"
    build_src "systools" "/usr/local/bin/colortest"
    build_src "taskman" "/usr/local/bin/xfce4-taskmanager"
    popd 1>/dev/null
    exit 0
fi

if [[ ! -f "/usr/local/bin/mpvcmd" ]]; then
    build_src "mpvcmd" "/usr/local/bin/mpvcmd"
    build_src "powerctl" "/usr/local/bin/powerctl"
    build_src "sysquery" "/usr/local/bin/sysquery"
    build_src "volman" "/usr/local/bin/volman"
    popd 1>/dev/null
    exit 0
fi

if [[ ! -f "/usr/local/bin/appinfo" ]]; then
    build_src "appinfo" "/usr/local/bin/appinfo"
    build_src "applist" "/usr/local/bin/applist"
    build_src "firebook" "/usr/local/bin/firebook"
    build_src "sfind" "/usr/local/bin/sfind"
    popd 1>/dev/null
    exit 0
fi

dest=/usr/local/bin/hoedown
if [[ ! -f "$dest" ]]; then
    echo " *** hoedown"
    git clone https://github.com/hoedown/hoedown.git
    pushd hoedown 1>/dev/null
    make && sudo make install
    sudo strip /usr/local/bin/hoedown
    popd 1>/dev/null
    exit 0
fi

# pop dir ---------------------------------------------------------------------

popd 1>/dev/null


