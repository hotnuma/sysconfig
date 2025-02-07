<link href="style.css" rel="stylesheet"></link>

## SysConfig

---

Experimental post install script for Debian XFCE.  
**This is an example script it must not be executed as is.**


#### System Install

* Install Debian

    https://www.debian.org/distrib/  
    https://www.debian.org/releases/stable/amd64/ch04s03.fr.html  
    
    Download an ISO file and copy it to a USB drive :
    
    `sudo dd if=<file> of=<device> bs=16M status=progress oflag=sync`
    
    or
    
    `sudo cp <file> <device> && sudo sync`
    
    where <device> is the all device such as `/dev/sdc`, not a partition.
    
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
    
    Predefined shorcut using super key :

    ```
    Super+Tab                           swith window in the same application
    Super+Arrows                        mosaic placing
    Super+P                             screen settings
    ```

    Run `xfce4-keyboard-settings` and add new hotkeys :

    ```
    fileman /home/hotnuma/Downloads/    Super+E
    firefox                             Super+B
    rofi -show run                      Super+Space
    systemctl poweroff                  Maj+Super+Q
    systemctl reboot                    Maj+Super+R
    xfce4-taskmanager                   Super+S
    xfce4-terminal                      Super+T
    ```
    
    run terminal in a specific directory :  
    
    https://unix.stackexchange.com/questions/676601/  
    
    `xfce4-terminal --default-working-directory=/home/hotnuma/Downloads/`
    
* Firefox
    
    Install uBlock Origin, SingleFile, cookies.txt.  
    Restore bookmarks, passwords, filters and user.js.  
    
    Test videos :  
    
    https://www.youtube.com/watch?v=cuXsupMuik4  
    https://www.youtube.com/watch?v=TVtoxUohG5E  
    
    Disable Filemanager service :
    
    https://bbs.archlinux.org/viewtopic.php?id=255794  
    https://unix.stackexchange.com/questions/66662/  
    https://askubuntu.com/questions/530779/  
    
    ```
    sudo mv /usr/share/dbus-1/services/org.xfce.FileManager.service .
    sudo mv /usr/share/dbus-1/services/org.xfce.Thunar.FileManager1.service .
    sudo mv /usr/share/dbus-1/services/org.xfce.Thunar.service .
    ```

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

* Disable grub background
    
    ```
    cat /etc/default/grub

    GRUB_DEFAULT=0
    GRUB_TIMEOUT=0
    GRUB_DISTRIBUTOR=`lsb_release -i -s 2> /dev/null || echo Debian`
    GRUB_CMDLINE_LINUX_DEFAULT="quiet"
    GRUB_CMDLINE_LINUX=""
    GRUB_BACKGROUND=
    ```

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

* Disable log messages

    https://github.com/hotnuma/doclinux/blob/master/01-Systemd.md#disable  

* User dirs
    
    edit user dirs .config/user-dirs.dirs

* Progams settings
    
    copy restore geany settings  
    copy mpv settings  

* Xfwm4

    Use resistance instead of magnet.
    
    If the panel is on top, disable drop down shasows :
    
    https://stackoverflow.com/questions/53725696/  

* Install yt-dlp
    
    https://github.com/yt-dlp/yt-dlp/wiki/Installation  
    
    ```
    wget https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp
    chmod a+rx ./yt-dlp
    sudo mv ./yt-dlp /usr/local/bin/
    ```
    
    To upgrade download the program again.

* Install QtCreator

    https://unix.stackexchange.com/questions/752145/  
    https://packages.debian.org/bookworm/qtcreator  
    https://packages.debian.org/source/bookworm/qt6-base  

    `./sysconfig qtcreator`  
    
    additional packages : `qtchooser qt6-tools-dev`

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
    
    In the `Project Page`, select : `Manage kits...`
    
    In `Qt Version`, browse to qmake path, such as :  
    `/usr/lib/qt6/bin/qmake`
    
    In the `Kits tab`, select the previously detected `Qt Version`.
    
    In the preferences of the editor, `Fonts and Colors`, set font
    size to 11 and select the `Default Classic` color scheme.

* gvfs-backends
    
    Provides `gvfs-mtp-volume-monitor` which permits to mount Android devices.
    
    Mask service :
    
    ```
    systemctl --user stop gvfs-mtp-volume-monitor
    systemctl --user mask gvfs-mtp-volume-monitor
    ```
    
    Unmask service :
    
    `rm $HOME/.config/systemd/user/gvfs-mtp-volume-monitor.service`
    
* Additional programs

    ```
    datamash
    evince
    feh
    freefilesync
    gnuplot
    greybird-gtk-theme
    lz4json
    plotutils
    sigil
    uchardet
    vainfo
    ```


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


