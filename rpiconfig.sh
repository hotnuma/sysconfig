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

model=$(tr -d '\0' </sys/firmware/devicetree/base/model)
test "$model" == "Raspberry Pi 4 Model B Rev 1.4" \
    || error_exit "wrong board model"

echo "===============================================================================" | tee -a "$outfile"
echo " Raspi config..." | tee -a "$outfile"
echo "===============================================================================" | tee -a "$outfile"

# test if sudo is succesfull ==================================================

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

# cpu governor ================================================================

dest="/etc/default/cpufrequtils"
if [[ ! -f $dest ]]; then
    echo "*** set governor to performance" | tee -a "$outfile"
    sudo tee "$dest" > /dev/null << 'EOF'
GOVERNOR="performance"
EOF
fi

#~ dest="~/.local/share/keyrings"
#~ if [[ -d $dest ]] && [[ ! -d ${dest}.bak ]]; then
    #~ echo "*** reset keyring password" | tee -a "$outfile"
	#~ cp -r "$dest" ${dest}.bak 
	#~ rm "$dest/*.keyring"
#~ fi

# rpi configuration ===========================================================

#~ dest="/boot/firmware/cmdline.txt"
#~ if [[ -f $dest ]] && [[ ! -f ${dest}.bak ]]; then
    #~ echo "*** edit /boot/cmdline.txt" | tee -a "$outfile"
    #~ sudo cp "$dest" ${dest}.bak 2>&1 | tee -a "$outfile"
    #~ sudo sed -i 's/ quiet splash plymouth.ignore-serial-consoles//' "$dest"
#~ fi

dest="/etc/default/raspi-firmware-custom"
if [[ ! -f $dest ]]; then
    echo "*** create /etc/default/raspi-firmware-custom" | tee -a "$outfile"
    sudo tee "$dest" > /dev/null << 'EOF'
# http://rpf.io/configtxt

dtoverlay=vc4-kms-v3d
max_framebuffers=2
arm_64bit=1
disable_overscan=1
disable_splash=1
boot_delay=0

# overclock
over_voltage=6
arm_freq=2000
gpu_freq=600

# audio
#dtparam=audio=on

# disable unneeded
dtoverlay=disable-bt
dtoverlay=disable-wifi
EOF
    sudo update-initramfs -u -k all
    echo "done" | tee -a "$outfile"
    exit 0
fi

#~ dest="/boot/firmware/config.txt"
#~ if [[ -f $dest ]] && [[ ! -f ${dest}.bak ]]; then
    #~ echo "*** edit /boot/firmware/config.txt" | tee -a "$outfile"
    #~ sudo cp "$dest" ${dest}.bak 2>&1 | tee -a "$outfile"
    #~ sudo tee "$dest" > /dev/null << 'EOF'
#~ # http://rpf.io/configtxt

#~ dtoverlay=vc4-kms-v3d
#~ max_framebuffers=2
#~ arm_64bit=1
#~ disable_overscan=1
#~ disable_splash=1
#~ boot_delay=0

#~ # overclock
#~ over_voltage=6
#~ arm_freq=2000
#~ gpu_freq=600

#~ # audio
#~ #dtparam=audio=on

#~ # disable unneeded
#~ dtoverlay=disable-bt
#~ dtoverlay=disable-wifi
#~ EOF
#~ fi

echo "done" | tee -a "$outfile"


