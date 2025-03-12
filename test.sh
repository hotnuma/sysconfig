#!/usr/bin/bash

basedir="$(dirname -- "$(readlink -f -- "$0";)")"

error_exit()
{
    msg="$1"
    test "$msg" != "" || msg="an error occurred"
    printf "*** $msg\nabort...\n"
    exit 1
}

dest="/usr/bin/plymouth"
if [[ -f "$dest" ]]; then
    echo "*** uninstall plymouth"
    sudo apt -y purge plymouth
fi

dest="/usr/bin/mousepad"
if [[ -f "$dest" ]]; then
    echo "*** uninstall mousepad"
    sudo apt -y purge mousepad
fi

