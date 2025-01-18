#!/usr/bin/bash

BASEDIR="$(dirname -- "$(readlink -f -- "$0";)")"
ARGS="$@"
YES=0

if [[ -f /boot/config.txt ]]; then
    DISTID="raspios"
    DISTVER="11"
fi


