#!/usr/bin/bash

BASEDIR="$(dirname -- "$(readlink -f -- "$0";)")"
DEBDIR="$BASEDIR/../debian"
CURRENTUSER="$USER"
OUTFILE="$HOME/install.log"

echo "===============================================================================" | tee -a $OUTFILE
echo " Sid Upgrade..." | tee -a $OUTFILE
echo "===============================================================================" | tee -a $OUTFILE

dest=/etc/apt/sources.list
if [[ ! -f ${dest}.bookworm ]]; then
    echo " *** upgrade" | tee -a $OUTFILE
	sudo cp "$dest" ${dest}.bookworm | tee -a $OUTFILE
	sudo sed -i -e 's/bookworm/unstable/g' /etc/apt/sources.list | tee -a $OUTFILE
	sudo apt update | tee -a $OUTFILE
	sudo apt upgrade | tee -a $OUTFILE
fi

# sources.list
#deb http://deb.debian.org/debian sid main contrib non-free non-free-firmware
#deb-src http://deb.debian.org/debian sid main contrib non-free

