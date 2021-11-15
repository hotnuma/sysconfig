#!/usr/bin/bash

#~ FF bookmark
#~ .config/shortcuts
#~ .config/mpv

dest=~/Config/backup/mpv
echo "*** copy mpv"
if [[ -d $dest ]]; then
    rm -rf $dest
fi
cp -r ~/config/mpv $dest


