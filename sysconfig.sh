#!/usr/bin/bash

BASEDIR="$(dirname -- "$(readlink -f -- "$0";)")"
BUILDDIR="$HOME/DevFiles"

# install ---------------------------------------------------------------------

if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    DISTID=$ID
    DISTVER=$VERSION_ID
elif [[ -f /etc/lsb-release ]]; then
    . /etc/lsb-release
    DISTID=$DISTRIB_ID
    DISTVER=$DISTRIB_RELEASE
fi

case $DISTID in
debian)
    $BASEDIR/debian/debian.sh
    ;;
Raspbian)
    echo "Unknown system"
    exit 1
    ;;
ubuntu)
    $BASEDIR/xubuntu/xubuntu.sh
    exit 1
    ;;
*)
    echo "Unknown system"
    exit 1
    ;;
esac

# build directory -------------------------------------------------------------

dest="$BUILDDIR"
if [[ ! -d "$dest" ]]; then
    echo "*** create build dir"
    mkdir "$BUILDDIR"
fi
pushd "$BUILDDIR"

# libtinyc --------------------------------------------------------------------

dest="/usr/local/include/tinyc/cstring.h"
pack="libtinyc"
if [[ ! -f "$dest" ]]; then
    echo "*** ${pack}"
    git clone https://github.com/hotnuma/${pack}.git
    pushd ${pack}
    ./install.sh
    popd
fi

# sysquery --------------------------------------------------------------------

dest="/usr/local/bin/sysquery"
pack="sysquery"
if [[ ! -f "$dest" ]]; then
    echo "*** ${pack}"
    git clone https://github.com/hotnuma/${pack}.git
    pushd ${pack}
    ./install.sh
    popd
fi

# systools --------------------------------------------------------------------

dest="/usr/local/bin/colortest"
pack="systools"
if [[ ! -f "$dest" ]]; then
    echo "*** ${pack}"
    git clone https://github.com/hotnuma/${pack}.git
    pushd ${pack}
    ./install.sh
    popd
fi

#~ fileman
#~ volman
#~ taskman
#~ firebook
#~ sfind
#~ powerctl
#~ docdev
#~ doclinux
#~ docfileman

#~ Adwaita-xfwm4
#~ testcmd
#~ testgtk
#~ prgen
#~ libtinycpp
#~ mpvcmd
#~ applist
#~ appinfo

# pop dir ---------------------------------------------------------------------

popd


