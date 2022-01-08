#!/usr/bin/bash

BASEDIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
OUTFILE="$HOME/install.log"
rm -f $OUTFILE

# test if sudo is succesfull -------------------------------------------

if [[ "$EUID" = 0 ]]; then
    echo "*** must not be run as root: abort." 2>&1 | tee -a $OUTFILE
    exit 1
else
    sudo -k
    if ! sudo true; then
        echo "*** sudo failed: abort." 2>&1 | tee -a $OUTFILE
        exit 1
    fi
fi

# passwordless sudo -------------------------------------------------

dest=/etc/sudoers.d/custom
if [[ ! -f $dest ]]; then
    echo "*** edit /etc/sudoers" 2>&1 | tee -a $OUTFILE
    sudo tee $dest > /dev/null << 'EOF'
hotnuma ALL=(ALL) NOPASSWD: ALL

EOF
fi

dest=/usr/bin/sway
if [[ ! -f $dest ]]; then
    echo "*** install desktop" 2>&1 | tee -a $OUTFILE
    sudo pacman -Syu 2>&1 | tee -a $OUTFILE
    sudo pacman -S mesa ttf-liberation otf-font-awesome 2>&1 | tee -a $OUTFILE
    sudo pacman -S sway swayidle waybar wofi thunar gvfs xfce4-terminal xorg-xeyes 2>&1 | tee -a $OUTFILE
    sudo pacman -S pipewire-media-session pipewire-pulse pipewire-zeroconf pulsemixer gst-libav 2>&1 | tee -a $OUTFILE
    sudo pacman -S pavucontrol pulseaudio-alsa alsa-utils pipewire-alsa 2>&1 | tee -a $OUTFILE
    sudo pacman -S gst-plugin-pipewire libva-v4l2-request 2>&1 | tee -a $OUTFILE
    sudo pacman -S wget htop geany xfce4-taskmanager 2>&1 | tee -a $OUTFILE
    sudo pacman -S git meson cmake base-devel 2>&1 | tee -a $OUTFILE
    sudo pacman -S mpv firefox firefox-ublock-origin 2>&1 | tee -a $OUTFILE
    sudo pacman -S engrampa 2>&1 | tee -a $OUTFILE
fi

dest=/boot/config.txt
if [[ ! -f $dest.bak ]]; then
    echo "*** edit /boot/config.txt" 2>&1 | tee -a $OUTFILE
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

dest=/etc/environment
if ! sudo grep -q "MOZ_ENABLE_WAYLAND" $dest; then
    echo "*** edit /etc/environment" 2>&1 | tee -a $OUTFILE
    sudo tee -a $dest > /dev/null << 'EOF'

MOZ_ENABLE_WAYLAND=1
MOZ_X11_EGL=1

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

dest=~/.config/labwc
if [[ ! -d $dest ]]; then
    echo " *** configure labwc" 2>&1 | tee -a $OUTFILE
    cp -a $BASEDIR/config/labwc/ ~/.config/ 2>&1 | tee -a $OUTFILE
fi

dest=~/.config/sway
if [[ ! -d $dest ]]; then
    echo " *** configure sway" 2>&1 | tee -a $OUTFILE
    cp -a $BASEDIR/config/sway/ ~/.config/ 2>&1 | tee -a $OUTFILE
fi

dest=~/.config/waybar
if [[ ! -d $dest ]]; then
    echo " *** configure waybar" 2>&1 | tee -a $OUTFILE
    cp -a $BASEDIR/config/waybar/ ~/.config/ 2>&1 | tee -a $OUTFILE
fi

## autologin : https://unix.stackexchange.com/questions/42359/
dest=~/.bash_profile
if ! grep -q "exec sway" $dest; then
    echo "*** autologin" 2>&1 | tee -a $OUTFILE
    tee -a $dest > /dev/null << 'EOF'

if [ -z $DISPLAY ] && [ “$(tty)” = “/dev/tty1” ]; then
    exec sway
fi
EOF
fi


