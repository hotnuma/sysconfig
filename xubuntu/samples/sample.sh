#!/usr/bin/bash

# Custom Session --------- -----------------------------------------------------

dest=/usr/share/xsessions/custom.desktop
if [[ ! -f $dest ]]; then
    echo "*** custom.desktop" 2>&1 | tee -a $OUTFILE
    sudo cp $BASEDIR/root/custom.desktop $dest 2>&1 | tee -a $OUTFILE
fi

dest=/usr/bin/startcustom
if [[ ! -f $dest ]]; then
    echo "*** startcustom" 2>&1 | tee -a $OUTFILE
    sudo cp $BASEDIR/root/startcustom $dest 2>&1 | tee -a $OUTFILE
fi

