#!/usr/bin/bash

basedir="$(dirname -- "$(readlink -f -- "$0";)")"

error_exit()
{
    msg="$1"
    test "$msg" != "" || msg="an error occurred"
    printf "*** $msg\nabort...\n"
    exit 1
}

