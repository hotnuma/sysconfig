
smartd

compton

dest=~/.config/compton.conf
if [[ ! -f $dest ]]; then
    echo " *** configure compton" | tee -a $OUTFILE
    cp $BASEDIR/config/compton.conf $dest 2>&1 | tee -a $OUTFILE
fi


