#!/usr/bin/bash

basedir="$(dirname -- "$(readlink -f -- "$0";)")"
devsrc="$HOME/DevSrc"
currentuser="$USER"
outfile="$HOME/install.log"
dist_id=""

error_exit()
{
    msg="$1"
    test "$msg" != "" || msg="an error occurred"
    printf "*** $msg\nabort...\n" | tee -a "$outfile"
    exit 1
}

# tests =======================================================================

if [[ "$EUID" = 0 ]]; then
    error_exit "*** must not be run as root"
else
    # make sure to ask for password on next sudo
    sudo -k
    if ! sudo true; then
        error_exit "*** sudo failed"
    fi
fi

if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    dist_id=$VERSION_CODENAME
fi

# parse options ---------------------------------------------------------------

while (($#)); do
    case "$1" in
        *)
        ;;
    esac
    shift
done

echo "===============================================================================" | tee -a $outfile
echo " Build src..." | tee -a $outfile
echo "===============================================================================" | tee -a $outfile

# build programs ==============================================================

dest="$devsrc"
if [[ ! -d "$dest" ]]; then
    echo "*** create build dir" | tee -a "$outfile"
    mkdir "$devsrc"
fi

pushd "$devsrc" 1>/dev/null

# labwc-tweaks-gtk ------------------------------------------------------------

dest=/usr/local/bin/labwc-tweaks-gtk
if [[ ! -f "$dest" ]]; then
    echo "*** build labwc-tweaks-gtk" | tee -a "$outfile"
    git clone https://github.com/labwc/labwc-tweaks-gtk.git \
    && pushd labwc-tweaks-gtk 1>/dev/null
    meson setup build | tee -a "$outfile"
    meson compile -C build | tee -a "$outfile"
    sudo meson install -C build | tee -a "$outfile"
    test "$?" -eq 0 || error_exit "installation failed"
    popd 1>/dev/null
fi

# rofi ------------------------------------------------------------

# https://github.com/lbonn/rofi  
# https://github.com/lbonn/rofi/blob/wayland/INSTALL.md#meson  

dest=/usr/local/bin/rofi
if [[ ! -f "$dest" ]]; then
    echo "*** build rofi" | tee -a "$outfile"
    sudo apt -y install bison flex
    git clone https://github.com/lbonn/rofi.git \
    && pushd rofi 1>/dev/null
    meson setup build -Dcheck=disabled -Dxcb=disabled \
    | tee -a "$outfile"
    ninja -C build | tee -a "$outfile"
    sudo ninja -C build install | tee -a "$outfile"
    popd 1>/dev/null
fi

dest=/usr/local/bin/rofi
pattern="command=\"wofi --show run\""
if [[ -f "$dest" ]] && [[ $(grep "$pattern" ~/.config/labwc/rc.xml) ]]; then
    echo "*** set rofi command" | tee -a "$outfile"
    sed -i \
    's|command=\"wofi --show run\"|command=\"/usr/local/bin/rofi -show run\"|g' \
    "$HOME/.config/labwc/rc.xml"
    labwc --reconfigure
fi

# pop dir ---------------------------------------------------------------------

popd 1>/dev/null
echo "done" | tee -a "$outfile"


