#!/usr/bin/bash

BASEDIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# test if sudo is succesfull -------------------------------------------

if [[ "$EUID" = 0 ]]; then
    echo "*** must not be run as root: abort."
    exit 1
else
    sudo -k # make sure to ask for password on next sudo
    if ! sudo true; then
        echo "*** sudo failed: abort."
        exit 1
    fi
fi

# set no password sudo -------------------------------------------------

dest=/etc/sudoers.d/custom
if [[ ! -f $dest ]]; then
    echo "*** edit /etc/sudoers"
    sudo tee $dest > /dev/null << 'EOF'
hotnuma ALL=(ALL) NOPASSWD: ALL

EOF
fi

# vulkan-broadcom mesa-demos pulseaudio 

dest=/usr/bin/sway
if [[ ! -f $dest ]]; then
    echo "*** install desktop"
    sudo pacman -Syu
    sudo pacman -S sway swayidle waybar wofi thunar gvfs xfce4-terminal
    sudo pacman -S pavucontrol pulseaudio-alsa alsa-utils pipewire-alsa
    sudo pacman -S pipewire-pulse pipewire-zeroconf pulsemixer gst-libav gst-plugin-pipewire libva-v4l2-request
    sudo pacman -S wget htop geany xfce4-taskmanager
    sudo pacman -S git meson base-devel
    sudo pacman -S mpv firefox firefox-ublock-origin
fi

dest=/etc/environment
if ! sudo grep -q "MOZ_ENABLE_WAYLAND" $dest; then
    echo "*** edit /etc/environment"
    sudo tee -a $dest > /dev/null << 'EOF'

MOZ_ENABLE_WAYLAND=1

EOF
fi

dest=/boot/config.txt
if [[ ! -f $dest.bak ]]; then
    echo "*** edit /boot/config.txt"
	sudo cp $dest $dest.bak
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
    echo " *** config link"
    ln -s ~/.config $dest
fi

dest=~/.config/autostart
if [[ ! -d $dest ]]; then
    echo " *** create autostart directory"
    mkdir -p $dest
fi

dest=~/.config/sway
if [[ ! -d $dest ]]; then
    echo " *** configure sway"
    cp -a $BASEDIR/config/sway/ ~/.config/
fi


