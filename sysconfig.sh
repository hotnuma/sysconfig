#!/usr/bin/bash

BASEDIR="$(dirname -- "$(readlink -f -- "$0";)")"
BUILDDIR="$HOME/DevFiles"

# install ---------------------------------------------------------------------

if [[ -f /etc/lsb-release ]]; then
    . /etc/lsb-release
    DISTNAME=$DISTRIB_ID
    DISTVER=$DISTRIB_RELEASE
elif [[ -f /etc/os-release ]]; then
    . /etc/os-release
    DISTNAME=$ID
    DISTVER=$VERSION_ID
fi

case $DISTNAME in
debian)
    $BASEDIR/debian/debian.sh
    ;;
Raspbian)
    echo "Unknown system"
    exit 1
    ;;
Ubuntu)
    echo "Unknown system"
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

# pop dir ---------------------------------------------------------------------

popd


