#!/usr/bin/bash

dest=$HOME/custom.txt
CURRENT_USER=$USER
if [[ ! -f $dest ]]; then
    echo "*** sudoers"
    sudo tee $dest > /dev/null << EOF
$CURRENT_USER ALL=(ALL) NOPASSWD: ALL
EOF
fi


