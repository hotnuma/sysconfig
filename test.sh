#!/usr/bin/bash

basedir="$(dirname -- "$(readlink -f -- "$0";)")"

error_exit()
{
    msg="$1"
    test "$msg" != "" || msg="an error occurred"
    printf "*** $msg\nabort...\n"
    exit 1
}

#~ dest="$HOME/.local/share/themes"
#~ if [[ ! -d "$dest/GTK" ]]; then
    #~ echo "*** install GTK theme" | tee -a "$outfile"
    #~ src="$basedir/labwc/gtktheme.zip"
    #~ unzip -d "$dest" "$src" 2>&1 | tee -a "$outfile"
    #~ test "$?" -eq 0 || error_exit "installation failed"
#~ fi

