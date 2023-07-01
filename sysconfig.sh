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

# install dev packages --------------------------------------------------------

#~ echo "*** install dev packages"
#~ APPLIST="libgtk-3-dev libpcre3-dev gettext xfce4-dev-tools"
#~ APPLIST+=" libxfconf-0-dev libxfce4ui-2-dev libwnck-3-dev libxmu-dev"
#~ sudo apt -y install $APPLIST

#~ libdbus-1-dev 	dbus-1
#~ libexiv2-dev 	exiv2
#~ libexo-2-dev 	exo-2
#~ libexpat1-dev 	expat
#~ libgdk-pixbuf-2.0-dev 	gdk-pixbuf-2.0
#~ libglib2.0-dev 	glib-2.0
#~ libgudev-1.0-dev 	gudev-1.0
#~ libgumbo-dev 	gumbo
#~ libmount-dev 	mount
#~ libnotify-dev 	libnotify
#~ libpng-dev 	libpng
#~ libpolkit-gobject-1-dev 	polkit-gobject-1
#~ libprocps-dev 	libprocps
#~ libsm-dev 	sm
#~ libthunarx-3-dev 	thunarx-3
#~ libtinyxml-dev 	tinyxml
#~ libusb-dev 	libusb
#~ libx11-dev 	x11
#~ libxfce4util-dev 	libxfce4util-1.0
#~ libxml2-dev 	libxml-2.0
#~ libz3-dev 	z3
#~ libzen-dev 	libzen

# build from git --------------------------------------------------------------

build_src()
{
    local pack="$1"
    local dest="$2"
    if [[ ! -f "$dest" ]]; then
        echo "*** ${pack}"
        git clone https://github.com/hotnuma/${pack}.git
        pushd ${pack}
        ./install.sh
        popd
    fi
}

build_src "libtinyc" "/usr/local/include/tinyc/cstring.h"
build_src "sysquery" "/usr/local/bin/sysquery"
build_src "systools" "/usr/local/bin/colortest"
build_src "taskman" "/usr/local/bin/xfce4-taskmanager"

#~ build_src "sfind" "/usr/local/bin/colortest"
#~ build_src "prgen" "/usr/local/bin/colortest"
#~ build_src "mpvcmd" "/usr/local/bin/colortest"
#~ build_src "appinfo" "/usr/local/bin/colortest"

#~ build_src "fileman" "/usr/local/bin/colortest"
#~ build_src "volman" "/usr/local/bin/colortest"

#~ build_src "firebook" "/usr/local/bin/colortest"
#~ build_src "powerctl" "/usr/local/bin/colortest"
#~ build_src "applist" "/usr/local/bin/colortest"

# pop dir ---------------------------------------------------------------------

popd


