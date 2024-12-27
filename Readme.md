<link href="style.css" rel="stylesheet"></link>

## SysConfig

---

Experimental post install scripts for XFCE, these are not recommended, use at your own risk. :-)

#### Todo
    
    edit user dirs .config/user-dirs.dirs
    
    xfce4-appearance-settings :  
    select adwata dark and then clair theme to have dark panel theme  
    set icon theme  elementary xfce  
    
    install and set wm theme : xfwm4-settings  
    ~/.local/share/themes or ~/.themes  
    ~/.local/share/themes/<theme_name>/xfwm4/  
    
    copy restore geany settings  
    copy mpv settings  
    
    disable ssh pgp
    
    manual uninstall of hv3 and zutty if needed  
    
    https://github.com/hotnuma/Adwaita-xfwm4/archive/refs/heads/master.zip  
    # todo use resistance instead of magnet  
    
    sudo apt install audacious freefilesync  
    
    if needed set user right to drive mount :  
    sudo chown -R $USER:$USER /media/hotnuma/Data/  
    
    
#### Post Install

* Install Debian

    https://www.debian.org/distrib/  
    https://www.debian.org/releases/stable/amd64/ch04s03.fr.html  
    
    Download an ISO file and copy it to a USB drive :
    
    ```
    sudo cp ./debian.iso /dev/sdX
    sudo sync
    ```
    
    https://www.youtube.com/watch?v=gddlhr9ST9Y  
    
    choose `Install` for the text based installer  
    let the domain name blank or enter a local domain such as : `mydomain.local`  
    let the root password blank in order to use `sudo`  

* Upgrade packages
    
    `sudo apt update; sudo apt upgrade`
    
* Install and Configure Git
    
    ```
    sudo apt install git
    git config --global user.name "John Doe"
    git config --global user.email johndoe@example.com
    ```

* Execute the script

    ```
    sudo apt update; sudo apt upgrade
    mkdir ~/DevFiles; cd ~/DevFiles
    git clone https://github.com/hotnuma/sysconfig.git; cd sysconfig
    ./debian/config.sh
    systemctl reboot
    ```


#### <a name="disable"></a> Manual configuration

* Configure hotkeys
    
    `xfce4-keyboard-settings`

    ```
    firefox                             Super+B
    rofi -show run                      Super+Space
    systemctl poweroff                  Maj+Super+Q
    systemctl reboot                    Maj+Super+R
    thunar /home/hotnuma/Downloads/     Super+E
    xfce4-taskmanager                   Super+S
    xfce4-terminal                      Super+T
    
    fileman /home/hotnuma/Downloads/    Super+E
    ```

* Firefox
    
    Restore bookmarks and passwords.  
    
    Disable overlay scrollbars :    `widget.gtk.overlay-scrollbars.enabled false`  
    Disable resume from crash :     `browser.sessionstore.resume_from_crash false`  
    
    Set always show scrollbars.  

* Firefox extensions

    ```
    uBlock Origin
    SingleFile
    ```

* XFCE Session
    
    Set don't save session, delete saved sessions.

* Configure Terminal
    
    Font :      DejaVu Sans Mono Book 9
    Geometry :  120 x 35

* Mount internal drives
    
    `sudo nano /usr/share/polkit-1/actions/org.freedesktop.UDisks2.policy`
    
    In the excerpt <action id=“org.freedesktop.udisks2.filesystem-mount-system”> in the defaults tag replace allow_active with yes :  

    `<allow_active>yes</allow_active>`
    
* Disable log messages

    https://github.com/hotnuma/doclinux/blob/master/01-Systemd.md#disable  


#### Graphic card

* Device nformations
    
    `sudo lspci -k | grep -EA3 'VGA|3D|Display'`

* Intel GPU
    
    https://wiki.debian.org/Firefox  
    https://wiki.debian.org/HardwareVideoAcceleration  
    https://christitus.com/fix-screen-tearing-linux/  
    https://bugzilla.mozilla.org/show_bug.cgi?id=1710400  
    
    `sudo apt purge xserver-xorg-video-intel`

* Video test

    https://www.youtube.com/watch?v=cuXsupMuik4  


<!--
* Hide grub menu

    https://askubuntu.com/questions/18775/  

    `sudo nano /etc/default/grub`
    
    change `GRUB_TIMEOUT=10` to `GRUB_TIMEOUT=0`
    save the file and quit the text editor.
    
    ```
    sudo update-grub
    systemctl reboot
    ```

* Add user to adm group
    
    `sudo usermod -a -G adm <username>`

* at-spi
    
    https://wiki.archlinux.de/title/GNOME#Tipps_und_Tricks  
    
    In `/etc/environment` add `NO_AT_BRIDGE=1`

* Overlay Scrollbars
    
    In `/etc/environment` add `GTK_OVERLAY_SCROLLING=0`

* AppArmor
    
    https://help.ubuntu.com/community/AppArmor  
    
    ```
    sudo systemctl stop apparmor
    sudo systemctl disable apparmor
    ```

* Autostart programs
    
    https://wiki.archlinux.org/title/XDG_Autostart  

    `echo "Hidden=true" > $HOME/.config/autostart/xcompmgr.desktop`

* systemd-oomd
    
    https://askubuntu.com/questions/1404888/  
    
    ```
    systemctl stop systemd-oomd
    systemctl disable systemd-oomd
    ```
-->


