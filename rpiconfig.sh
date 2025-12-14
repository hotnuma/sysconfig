#!/usr/bin/bash

basedir="$(dirname -- "$(readlink -f -- "$0";)")"
currentuser="$USER"
outfile="$HOME/install.log"

error_exit()
{
    msg="$1"
    test "$msg" != "" || msg="an error occurred"
    printf "*** $msg\nabort...\n" | tee -a "$outfile"
    exit 1
}

test ! -d "/boot/grub" || error_exit "not a Raspberry Pi"

echo "===============================================================================" | tee -a "$outfile"
echo " Raspi config..." | tee -a "$outfile"
echo "===============================================================================" | tee -a "$outfile"

# test if sudo is succesfull --------------------------------------------------

if [[ "$EUID" = 0 ]]; then
    echo "*** must not be run as root, abort..." | tee -a "$outfile"
    exit 1
else
    sudo -k
    if ! sudo true; then
        echo "*** sudo failed, abort..." | tee -a "$outfile"
        exit 1
    fi
fi

# raspios ---------------------------------------------------------------------

dest="/boot/firmware/config.txt"
if [[ -f "$dest" ]] && [[ ! -f "${dest}.bak" ]]; then
    echo "*** edit /boot/firmware/config.txt" | tee -a "$outfile"
    sudo cp "$dest" "${dest}.bak" 2>&1 | tee -a "$outfile"
    sudo tee "$dest" > /dev/null << 'EOF'
# https://www.raspberrypi.com/documentation/computers/config_txt.html

# default config
auto_initramfs=1
dtoverlay=vc4-kms-v3d
max_framebuffers=2
arm_64bit=1
disable_overscan=1

# user config
disable_splash=1
dtoverlay=disable-bt
dtoverlay=disable-wifi

[pi4]
arm_freq=2000
gpu_freq=600

[pi5]
usb_max_current_enable=1
EOF
fi

echo "done" | tee -a "$outfile"


