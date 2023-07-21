#!/usr/bin/bash

BASEDIR="$(dirname -- "$(readlink -f -- "$0";)")"
BUILDDIR="$HOME/DevFiles"

# build directory -------------------------------------------------------------

dest="$BUILDDIR"
if [[ ! -d "$dest" ]]; then
    echo " *** create build dir"
    mkdir "$BUILDDIR"
fi
pushd "$BUILDDIR"

# install dev packages --------------------------------------------------------

#~ dest=/usr/include/gumbo.h
#~ if [[ ! -f "$dest" ]]; then
    #~ echo " *** install dev packages"
    #~ APPLIST="gettext xfce4-dev-tools"
    #~ sudo apt -y install $APPLIST
#~ fi

#~ libdbus-1-dev 	dbus-1
#~ libexiv2-dev 	exiv2
#~ libexo-2-dev 	exo-2
#~ libexpat1-dev 	expat
#~ libgdk-pixbuf-2.0-dev 	gdk-pixbuf-2.0
#~ libglib2.0-dev 	glib-2.0
#~ libgudev-1.0-dev 	gudev-1.0
#~ libmount-dev 	mount
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
        echo " *** ${pack}"
        git clone https://github.com/hotnuma/${pack}.git
        pushd ${pack}
        ./install.sh
        popd
    fi
}

dest="/usr/include/tinyc/cstring.h"
if [[ ! -f "$dest" ]]; then
    echo " *** libtinyc"
    git clone https://github.com/hotnuma/libtinyc.git
    pushd libtinyc
    meson setup build --prefix /usr -Dbuildtype=debug
    ninja -C build
    sudo ninja -C build install
    popd
fi

#~ build_src "fileman" "/usr/local/bin/fileman"
#~ build_src "taskman" "/usr/local/bin/xfce4-taskmanager"
build_src "sysquery" "/usr/local/bin/sysquery"
build_src "systools" "/usr/local/bin/colortest"

#~ build_src "appinfo" "/usr/local/bin/appinfo"
#~ build_src "applist" "/usr/local/bin/applist"
#~ build_src "firebook" "/usr/local/bin/firebook"
#~ build_src "sfind" "/usr/local/bin/sfind"

#~ build_src "prgen" "/usr/local/bin/prgen"
#~ build_src "mpvcmd" "/usr/local/bin/mpvcmd"
#~ build_src "volman" "/usr/local/bin/volman"
#~ build_src "powerctl" "/usr/local/bin/powerctl"

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


