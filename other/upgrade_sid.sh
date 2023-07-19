#!/usr/bin/bash

BASEDIR="$(dirname -- "$(readlink -f -- "$0";)")"
DEBDIR="$BASEDIR/../debian"
CURRENTUSER="$USER"
OUTFILE="$HOME/install.log"

echo "===============================================================================" | tee -a $OUTFILE
echo " Sid Upgrade..." | tee -a $OUTFILE
echo "===============================================================================" | tee -a $OUTFILE

dest=/etc/apt/sources.list
if [[ ! -f ${dest}.bak ]]; then
    echo " *** upgrade" | tee -a $OUTFILE
	sudo cp "$dest" ${dest}.bak | tee -a $OUTFILE
	sudo sed -i -e 's/bookworm/sid/g' /etc/apt/sources.list | tee -a $OUTFILE
	sudo apt update | tee -a $OUTFILE
	sudo apt upgrade | tee -a $OUTFILE
fi


