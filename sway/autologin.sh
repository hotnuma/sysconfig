#!/bin/bash

## autologin : https://unix.stackexchange.com/questions/42359/how-can-i-autologin-to-desktop-with-systemd

dest=~/.bash_profile
if ! grep -q "exec sway" $dest; then
    echo "*** edit bash profile"
    tee -a $dest > /dev/null << 'EOF'

if [ -z $DISPLAY ] && [ “$(tty)” = “/dev/tty1” ]; then
exec sway
fi
EOF
fi

dest=/etc/sudoers
if ! sudo grep -q "hotnuma" $dest; then
    echo "*** edit /etc/sudoers"
    sudo tee -a $dest > /dev/null << 'EOF'

hotnuma ALL=(ALL) NOPASSWD: ALL

EOF
fi


