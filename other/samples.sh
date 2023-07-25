
# picom -----------------------------------------------------------------------

dest=~/.config/picom
if [[ ! -d $dest ]]; then
    echo " *** configure picom" | tee -a $OUTFILE
    mkdir -p $dest 2>&1 | tee -a $OUTFILE
    cp $BASEDIR/home/picom.conf "$dest/picom.conf" 2>&1 | tee -a $OUTFILE
fi


