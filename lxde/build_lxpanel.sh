#!/usr/bin/bash

# Prepare system -------------------------------------------------------
#
dest=~/DevFiles
if [[ ! -d $dest ]]; then
    mkdir ~/DevFiles
fi

# dependencies
# intltool wireless_tools

dest=~/DevFiles/lxpanel
if [[ ! -d $dest ]]; then
    cd ~/DevFiles
    git clone https://github.com/lxde/lxpanel.git
    cd $dest
	sed -i '/pager.c/d' plugins/Makefile.am
    sed -i '/STATIC_PAGER/d' src/private.h
	sed -i 's/libwnck-3.0//' configure.ac
	autoreconf -fi
fi

#~ --prefix=/usr

dest=~/DevFiles/lxpanel
if [[ -d $dest ]]; then
    cd $dest
    ./configure \
    --sysconfdir=/etc \
    --enable-gtk3

    #https://bugzilla.gnome.org/show_bug.cgi?id=656231
    sed -i -e 's/ -shared / -Wl,-O1,--as-needed\0/g' libtool

    make
    sudo make install
fi


