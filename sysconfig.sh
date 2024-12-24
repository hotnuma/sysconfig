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
pushd "$BUILDDIR"

# build from git --------------------------------------------------------------

build_src()
{
    local pack="$1"
    local dest="$2"
    if [[ ! -f "$dest" ]]; then
        echo " *** ${pack}"
        git clone https://github.com/hotnuma/${pack}.git
        pushd ${pack}
        ./install.sh
        popd
    fi
}

if [[ ! -f "/usr/local/include/tinyc/cstring.h" ]]; then
    build_src "libtinyc" "/usr/local/include/tinyc/cstring.h"
    build_src "fileman" "/usr/local/bin/fileman"
    build_src "sysquery" "/usr/local/bin/sysquery"
    build_src "systools" "/usr/local/bin/colortest"
fi

#~ build_src "taskman" "/usr/local/bin/xfce4-taskmanager"
#~ build_src "mpvcmd" "/usr/local/bin/mpvcmd"
#~ build_src "volman" "/usr/local/bin/volman"
#~ build_src "powerctl" "/usr/local/bin/powerctl"

#~ build_src "appinfo" "/usr/local/bin/appinfo"
#~ build_src "applist" "/usr/local/bin/applist"
#~ build_src "firebook" "/usr/local/bin/firebook"
#~ build_src "sfind" "/usr/local/bin/sfind"


#~ dest=/usr/local/bin/hoedown
#~ if [[ ! -f "$dest" ]]; then
    #~ echo " *** hoedown"
    #~ git clone https://github.com/hoedown/hoedown.git
    #~ pushd hoedown
    #~ make && sudo make install
    #~ sudo strip /usr/local/bin/hoedown
    #~ popd
#~ fi

# pop dir ---------------------------------------------------------------------

popd


