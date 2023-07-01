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

# application menu ------------------------------------------------------------

dest=$HOME/.config/menus/xfce-applications.menu
if [[ ! -f "$dest" ]]; then
    echo "*** application menu" | tee -a "$OUTFILE"
    mkdir -p "$HOME/.config/menus"
    cp "$DEBDIR/home/xfce-applications.menu" "$dest" 2>&1 | tee -a "$OUTFILE"
fi



# hplj1020.desktop (printer-driver-foo2zjs-common)
dest=$HOME/.local/share/applications/hplj1020.desktop
if [[ ! -f $dest ]]; then
    echo "*** hide hplj1020.desktop" 2>&1 | tee -a $OUTFILE
    echo "NoDisplay=true" > $dest
fi

