#!/usr/bin/bash

BASEDIR="$(dirname -- "$(readlink -f -- "$0";)")"
BUILDDIR="$HOME/DevFiles"

# install ---------------------------------------------------------------------

$BASEDIR/debian/debian.sh

# build directory -------------------------------------------------------------

dest="$BUILDDIR"
if [[ ! -d "$dest" ]]; then
    echo "*** create build dir"
    mkdir "$BUILDDIR"
fi
pushd "$BUILDDIR"

# libtinyc --------------------------------------------------------------------

dest="/usr/local/include/tinyc/cstring.h"
if [[ ! -f "$dest" ]]; then
    echo "*** libtinyc"
    git clone https://github.com/hotnuma/libtinyc.git
    pushd libtinyc
    ./install.sh
    popd
fi

# sysquery --------------------------------------------------------------------

dest="/usr/local/bin/sysquery"
if [[ ! -f "$dest" ]]; then
    echo "*** sysquery"
    git clone https://github.com/hotnuma/sysquery.git
    pushd sysquery
    ./install.sh
    popd
fi

popd


