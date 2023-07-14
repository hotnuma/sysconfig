#!/usr/bin/bash

BASEDIR="$(dirname -- "$(readlink -f -- "$0";)")"
DEBDIR="$BASEDIR/../debian"
CURRENTUSER="$USER"
OUTFILE="$HOME/install.log"

echo "===============================================================================" | tee -a $OUTFILE
echo " Configuration..." | tee -a $OUTFILE
echo "===============================================================================" | tee -a $OUTFILE

# numlock/autologin -----------------------------------------------------------

dest=/etc/lightdm/lightdm.conf
if [[ ! -f ${dest}.bak ]]; then
    echo "*** autologin" | tee -a "$OUTFILE"
    sudo cp "$dest" ${dest}.bak 2>&1 | tee -a "$OUTFILE"
    sudo tee "$dest" > /dev/null << EOF
[Seat:*]
autologin-guest=false
autologin-user=$CURRENTUSER
autologin-user-timeout=0
#autologin-session=lightdm-xsession
EOF
fi


