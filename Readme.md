<link href="style.css" rel="stylesheet"></link>

## SysConfig

---

Post install scripts for XFCE, these are meant to be
some examples and **must not be executed as is**.
Use at your own risk. :-)


#### System Install

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
    let the root password blank in order to use `sudo`.  

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
    xfce4-taskmanager                   Super+S
    xfce4-terminal                      Super+T
    ```

* Firefox
    
    Install uBlock Origin, SingleFile, cookies.txt. Restore bookmarks and passwords.  
    
    Disable overlay scrollbars : `widget.gtk.overlay-scrollbars.enabled false`  
    Disable resume from crash : `browser.sessionstore.resume_from_crash false`  

* Configure Terminal
    
    Font :      DejaVu Sans Mono Book 11
    Geometry :  90 x 35

* XFCE Session
    
    On log out, set don't save session, delete saved sessions.

* Mount internal drives
    
    `sudo nano /usr/share/polkit-1/actions/org.freedesktop.UDisks2.policy`
    
    In the excerpt <action id=“org.freedesktop.udisks2.filesystem-mount-system”> in the defaults tag replace `allow_active` with yes :  

    `<allow_active>yes</allow_active>`

* USB keys access rights

    If needed, set user right to the drive mount point :
    
    `sudo chown -R $USER:$USER /media/$USER/Data/`

* Install QtCreator
    
    https://packages.debian.org/bookworm/qtcreator  
    https://packages.debian.org/source/bookworm/qt6-base  

    `sudo apt install qtcreator qt6-base-dev`

    It may require additional packages :
    
    `qtchooser qmake6 cmake`

    Disable unneeded plugins :
    
    ```
    QbsProjectManager
    Help
    Welcome
    Android
    Qnx
    RemoteLinux
    Modeling
    GLSLEditor
    Qt Quick
    FakeVim
    Version Control
    ```
    
    Select Qt6 kit :
    
    ```
    /usr/bin/qmake
    /usr/lib/qt6/bin/qmake
    ```


* Disable log messages

    https://github.com/hotnuma/doclinux/blob/master/01-Systemd.md#disable  

* Install Adwaita-xfwm4 theme
    
    ```
    wget https://github.com/hotnuma/Adwaita-xfwm4/archive/refs/heads/master.tar.gz
    tar xzf master.tar.gz
    mkdir $HOME/.themes
    mv ./Adwaita-xfwm4-master $HOME/.themes/Adwaita-xfwm4
    ```

* Panel dark mode

    Run `xfce4-appearance-settings`, select adwata dark and then clair theme to
    have dark panel working.

* Icon theme

    set icon theme  elementary xfce  

* User dirs
    
    edit user dirs .config/user-dirs.dirs

* Progams settings
    
    copy restore geany settings  
    copy mpv settings  

* Xfwm4

    Use resistance instead of magnet.
    
    If the panel is on top, disable drop down shasows :
    
    https://stackoverflow.com/questions/53725696/  

* Additional programs

    `datamash freefilesync gnuplot plotutils sigil`


#### Graphic card

* Video test

    https://www.youtube.com/watch?v=cuXsupMuik4  

* Device nformations
    
    `sudo lspci -k | grep -EA3 'VGA|3D|Display'`

* Intel GPU
    
    https://wiki.debian.org/Firefox  
    https://wiki.debian.org/HardwareVideoAcceleration  
    https://christitus.com/fix-screen-tearing-linux/  
    https://bugzilla.mozilla.org/show_bug.cgi?id=1710400  
    
    `sudo apt purge xserver-xorg-video-intel`


