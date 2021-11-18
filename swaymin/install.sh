#!/bin/bash

# vulkan-broadcom

dest=/usr/bin/sway
if [[ ! -f $dest ]]; then
    echo "*** install desktop"
    sudo pacman -Syu
    sudo pacman -S mesa-demos sway swayidle wofi xfce4-terminal thunar
    sudo pacman -S gvfs pulseaudo htop
    sudo pacman -S geany firefox firefox-ublock-origin
    mkdir ~/.config
    mkdir ~/.config/sway
    cp -pr /backup/config_minimal/config ~/.config/sway/config
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


