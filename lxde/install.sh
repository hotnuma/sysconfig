#!/usr/bin/bash

BASEDIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
OUTFILE="$HOME/install.log"
rm -f $OUTFILE

# test if sudo is succesfull -------------------------------------------

if [[ "$EUID" = 0 ]]; then
    echo " *** must not be run as root: abort." 2>&1 | tee -a $OUTFILE
    exit 1
else
    sudo -k
    if ! sudo true; then
        echo " *** sudo failed: abort." 2>&1 | tee -a $OUTFILE
        exit 1
    fi
fi

# passwordless sudo -------------------------------------------------

dest=/etc/sudoers.d/custom
if [[ ! -f $dest ]]; then
    echo " *** edit /etc/sudoers" 2>&1 | tee -a $OUTFILE
    sudo tee $dest > /dev/null << 'EOF'
hotnuma ALL=(ALL) NOPASSWD: ALL

EOF
fi

dest=/usr/bin/openbox
if [[ ! -f $dest ]]; then
    echo " *** install desktop" 2>&1 | tee -a $OUTFILE
    sudo pacman -Syu 2>&1 | tee -a $OUTFILE

    paklist="xorg ttf-liberation mesa openbox lxsession-gtk3 lxpanel-gtk3 \
    pcmanfm-gtk3 lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings \
    lxde-common lxde-icon-theme lxlauncher-gtk3 lxinput-gtk3 lxhotkey-gtk3 \
    lxrandr-gtk3 lxappearance-gtk3 lxappearance-obconf-gtk3 lxtask-gtk3"
    sudo pacman -S $paklist 2>&1 | tee -a $OUTFILE
    
    paklist="thunar gvfs xfce4-terminal xfce4-taskmanager wget htop geany \
    mpv firefox firefox-ublock-origin engrampa meson cmake base-devel"
    sudo pacman -S $paklist 2>&1 | tee -a $OUTFILE
    
    sudo systemctl enable lightdm.service --force 2>&1 | tee -a $OUTFILE
fi

dest=/usr/bin/git
if [[ ! -f $dest ]]; then
    echo " *** install git" 2>&1 | tee -a $OUTFILE
    paklist="git"
    sudo pacman -S $paklist 2>&1 | tee -a $OUTFILE
fi

dest=/boot/config.txt
if [[ ! -f $dest.bak ]]; then
    echo " *** edit config.txt" 2>&1 | tee -a $OUTFILE
    sudo cp $dest $dest.bak 2>&1 | tee -a $OUTFILE
    sudo tee $dest > /dev/null << 'EOF'
# See /boot/overlays/README for all available options

initramfs initramfs-linux.img followkernel
kernel=kernel8.img
arm_64bit=1
disable_overscan=1

#enable sound
dtparam=audio=on
#hdmi_drive=2

# enable vc4
dtoverlay=vc4-kms-v3d
max_framebuffers=2
gpu_mem=256
disable_splash=1

# overclocking
arm_freq=2000
over_voltage=6
gpu_freq=600

# disable unneeded
dtoverlay=disable-wifi
dtoverlay=disable-bt

EOF
fi

# /home settings -------------------------------------------------------

dest=~/config
if [[ ! -d $dest ]]; then
    echo " *** config link" 2>&1 | tee -a $OUTFILE
    ln -s ~/.config $dest 2>&1 | tee -a $OUTFILE
fi

dest=~/.config/autostart
if [[ ! -d $dest ]]; then
    echo " *** create autostart directory" 2>&1 | tee -a $OUTFILE
    mkdir -p $dest 2>&1 | tee -a $OUTFILE
fi


