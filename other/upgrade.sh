#!/usr/bin/bash

BASEDIR="$(dirname -- "$(readlink -f -- "$0";)")"
DEBDIR="$BASEDIR/../debian"
CURRENTUSER="$USER"
OUTFILE="$HOME/install.log"

echo "===============================================================================" | tee -a $OUTFILE
echo " Bookworm Upgrade..." | tee -a $OUTFILE
echo "===============================================================================" | tee -a $OUTFILE

dest=/etc/apt/sources.list
if [[ ! -f ${dest}.bak ]]; then
    echo " *** upgrade" | tee -a $OUTFILE
	sudo cp "$dest" ${dest}.bak | tee -a $OUTFILE
	sudo sed -i -e 's/bullseye/bookworm/g' /etc/apt/sources.list | tee -a $OUTFILE
	sudo apt update | tee -a $OUTFILE
	sudo apt upgrade | tee -a $OUTFILE
fi

#sudo sed -i -e 's/bullseye/bookworm/g' /etc/apt/sources.list.d/raspi.list
#~ sudo apt -y full-upgrade
#~ sudo apt -y autoremove
#~ sudo apt -y clean
#~ sudo reboot

# remove old config files after doing sanity checks
#sudo apt purge ?config-files


