#!/usr/bin/bash

BASEDIR="$(dirname -- "$(readlink -f -- "$0";)")"
OUTFILE="$HOME/install.log"

echo "===============================================================================" | tee -a $OUTFILE
echo " Screen tearing fix..." | tee -a $OUTFILE
echo "===============================================================================" | tee -a $OUTFILE

dest=/usr/bin/startmod
if [[ ! -f $dest ]]; then
    echo " *** startmod script" | tee -a $OUTFILE
    sudo cp $BASEDIR/config/startmod $dest 2>&1 | tee -a $OUTFILE
fi

dest=/usr/share/xsessions/custom.desktop
if [[ ! -f $dest ]]; then
    echo " *** custom session" | tee -a $OUTFILE
    sudo tee $dest > /dev/null << 'EOF'
[Desktop Entry]
Name=LXDE
Comment=LXDE - Lightweight X11 desktop environment
Exec=/usr/bin/startmod
Type=Application
EOF
fi

dest=~/.dmrc
if [[ ! -f $dest ]]; then
    echo " *** dmrc" | tee -a $OUTFILE
    tee $dest > /dev/null << 'EOF'
[Desktop]
Session=custom
EOF
fi

echo "done" | tee -a $OUTFILE


