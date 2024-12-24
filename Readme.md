<link href="style.css" rel="stylesheet"></link>

## SysConfig

---

Experimental post install scripts for XFCE, these are not recommended, use at your own risk. :-)


#### Post Install

* Configure Git
    
    ```
    git config --global user.name "John Doe"
    git config --global user.email johndoe@example.com
    ```

* Execute the script

    `mkdir ~/DevFiles; cd ~/DevFiles`
    
    `git clone https://github.com/hotnuma/sysconfig.git; cd sysconfig`
    
    `./debian/config.sh`


#### <a name="disable"></a> Manual configuration

* Hide grub menu

    https://askubuntu.com/questions/18775/  

    `sudo nano /etc/default/grub`
    
    change `GRUB_TIMEOUT=10` to `GRUB_TIMEOUT=0`
    save the file and quit the text editor.
    
    ```
    sudo update-grub
    systemctl reboot
    ```

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
    
    Disable resume from crash : `browser.sessionstore.resume_from_crash false`.

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


