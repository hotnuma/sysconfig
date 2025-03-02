<link href="style.css" rel="stylesheet"></link>

## Raspios

---

#### References

https://forums.raspberrypi.com/search.php?search_id=newposts  

https://www.raspberrypi.com/documentation/  
https://www.raspberrypi.com/documentation/computers/raspberry-pi.html  
https://linuxhint.com/gpio-pinout-raspberry-pi/  
[tearing_test](https://www.youtube.com/watch?v=cuXsupMuik4)  
[howto_desktops](https://forums.raspberrypi.com/viewtopic.php?t=133691)  
[howto_autostart](https://forums.raspberrypi.com/viewtopic.php?t=294014)  

https://downloads.raspberrypi.org/raspios_arm64/images/  
https://github.com/orgs/raspberrypi-ui/repositories  
https://github.com/orgs/RPi-Distro/repositories  
https://github.com/orgs/raspberrypi/repositories  
https://github.com/raspberrypi/rpi-eeprom  

[best-ssd-storage](https://jamesachambers.com/best-ssd-storage-adapters-for-raspberry-pi-4-400/)  


#### System informations

* kernel, firmware, bootloader, eeprom

    ```
    uname -a
    vcgencmd version
    vcgencmd bootloader_version
    vcgencmd bootloader_config
    rpi-eeprom-config
    ```

* Board model
    
    `cat /sys/firmware/devicetree/base/model`

* Read CPU temperature

    `vcgencmd measure_temp`

* Release notes : 
    
    https://downloads.raspberrypi.org/raspios_arm64/release_notes.txt  


#### Raspios configuration

https://www.raspberrypi.com/documentation/computers/os.html  

* Change hostname, disable xcompmgr

    ```
    sudo raspi-config
    ```

* Revert to specific firmware using git commit hash

    ```
    sudo rpi-update 6e61ab523f0a9d2fbb4319f6f6430d4c13203c0e
    ```

* Revert to stable firmware

    ```
    sudo apt update
    sudo apt install --reinstall libraspberrypi0 libraspberrypi-{bin,dev,doc} raspberrypi-bootloader raspberrypi-kernel
    ```


#### Startup Sequence

```
/sbin/ini

  graphical.target

  lightdm
    Xorg
    lightdm --session-child 14 17
      lxsession -s LXDE-pi -e LXDE
    
    systemd/systemd --user
```


#### LightDM

* Configuration

    `/etc/lightdm/lightdm.conf`

    `lightdm --show-config`

    ```
    [LightDM]

    [Seat:*]
    greeter-session=pi-greeter
    greeter-hide-users=false
    display-setup-script=/usr/share/dispsetup.sh
    autologin-user=username

    [XDMCPServer]
    [VNCServer]
    ```

* Session

    https://askubuntu.com/questions/77191/  

    _The Name entry is what lightdm would display for this session. The Exec entry is the important thing, and it should be the name of the program that starts the actual session. When you log in, lightdm calls the /etc/X11/Xsession script, passing it the value of Exec as an argument, and Xsession will, eventually, execute this program (for example, it could be startxfce4 for starting a xfce4 session). If the Exec entry is the special string default, then Xsession will execute the user's ~/.xsession file. (Xsession would also execute ~/.xsession if it's called without arguments.)_

    `DESKTOP_SESSION=LXDE-pi`

    `~/.dmrc`

    ```
    [Desktop]
    Session=lightdm-xsession
    ```

    `/usr/share/xsessions/lightdm-xsession.desktop`

    ```
    [Desktop Entry]
    Version=1.0
    Name=Default Xsession
    Exec=default
    Icon=
    Type=Application
    ```
    
    Startup script : `/usr/bin/startlxde-pi`


#### Openbox

* Config

    Openbox is set in `~/config/lxsession/LXDE-pi/desktop.conf` using a wrapper script.

    ```
    cat /usr/bin/openbox-lxde-pi 
    #!/bin/sh
    exec openbox --config-file $XDG_CONFIG_HOME/openbox/lxde-pi-rc.xml $@
    ```

    The default config file should be `$HOME/.config/openbox/lxde-pi-rc.xml` but it's possible to set openbox in `desktop.conf` and use `/home/pi/.config/openbox/rc.xml`

    ```
    [Session]
    window_manager=openbox
    ```

* Reload openbox config :

    ```
    openbox --reconfigure
    ```

* Picom
    
    https://wiki.archlinux.org/title/picom  
    
    `picom --backend glx`


#### Application menu

`/etc/xdg/menus/lxde-pi-applications.menu`


#### Xfce

* Switch to network-manager
    
    `sudo raspi-config` advanced configuration, network.

* Install Xfce
    
    Switch to NetworkManager, install xfce desktop :
    
    `sudo apt install xfce4`
    
    Set xfce session :

    `~/.dmrc`

    ```
    [Desktop]
    Session=xfce
    ```

* Fix screen tearing
    
    https://forum.manjaro.org/t/how-to-fix-intel-screen-tearing-on-xfce/31361/1  
    
    ```
    1- Go to “setting manager”
    2- Go to “setting editor”
    3- Choose “xfwm4”
    4- Find “vblank_mode” and select
    5- Press the “edit”
    6- Type glx to “value” section
    7- Save and reboot

    Note: This is the gui way of those commands
    xfwm4 --replace --vblank=glx &
    xfconf-query -c xfwm4 -p /general/vblank_mode -s glx
    ```


#### Browser

https://forums.raspberrypi.com/viewtopic.php?t=331397  
https://bugzilla.mozilla.org/show_bug.cgi?id=1663285  
https://bugzilla.mozilla.org/show_bug.cgi?id=1725624  


#### Other

* SSD Boot
    
    Change boot order with `raspi-config`
    
    View current EEPROM configuration : `rpi-eeprom-config`
    
    Edit configuration : `sudo -E rpi-eeprom-config --edit`
    
    Add `USB_MSD_DISCOVER_TIMEOUT=5`
    
    [udev_trim](https://forums.raspberrypi.com/viewtopic.php?t=307276#p1839171)  

* Upgrade to Debian 12
    
    [rpios_bookworm](https://forums.raspberrypi.com/viewtopic.php?t=352477)  
    [upgrade_bookworm](https://forums.raspberrypi.com/viewtopic.php?p=2110754)  
    [metapackages_bookworm](https://forums.raspberrypi.com/viewtopic.php?t=351201)  
    
    https://gist.github.com/jauderho/6b7d42030e264a135450ecc0ba521bd8  
    https://blog.fernvenue.com/archives/upgrade-raspberrypi-to-debian-12-bookworm/  
    
* CPU governor

    https://askubuntu.com/questions/1021748/  
    https://raspberrypi.stackexchange.com/questions/9034/  

* Display settings

    https://forums.raspberrypi.com/viewtopic.php?p=1945199#p1945199  
    https://forums.raspberrypi.com/viewtopic.php?p=1945198#p1945198  
    https://forums.raspberrypi.com/viewtopic.php?t=325011#p1945199  
    
    `video=HDMI-1:800x480@60`

* Glamor
    
    `/usr/share/X11/xorg.conf.d/20-noglamor.conf`

* USB Chipset
    
    https://forums.raspberrypi.com/viewtopic.php?t=245931  
    https://forums.raspberrypi.com/viewtopic.php?t=326157  
    
    ```
    That's true for most of the JMS578 family of USB 3.0 bridge chips,
    but not necessarily with the 580 series USB 3.1 chips.
    I have a USB 3.1 Gen 2 enclosure with a JMS583 chip that works
    fine with Pi computers. It supports UASP in RPiOS, and TRIM works
    with a udev rule.
    ```

* Test RPi version

    https://forums.raspberrypi.com/viewtopic.php?t=34678  
    https://forums.raspberrypi.com/viewtopic.php?t=200059  

    ```
    ARCH=$(uname -m)
    VERSION=$(cat /etc/debian_version)
    if [[ $ARCH != "aarch64" ]] || [[ $VERSION != 11* ]]; then
        echo " *** This script was tested only on a Raspberry Pi 4B 64 bit"
        echo " *** abort..."
        exit 1
    fi

    cat /proc/cpuinfo
    grep -q BCM2708 /proc/cpuinfo
    cat /etc/*-release
    cat /proc/device-tree/model
    cat /sys/firmware/devicetree/base/model
    ```

* Transfer Data Through Bluetooth
    
    [https://linuxhint.com/transfer-data-through-bluetooth-raspbe](https://linuxhint.com/transfer-data-through-bluetooth-raspberry-pi/)  

* GPIO Programming

    https://forums.raspberrypi.com/viewtopic.php?t=327539  

* C++ SSD1306 I2C LCD
    
    https://forums.raspberrypi.com/viewtopic.php?t=224984  
    https://forums.raspberrypi.com/viewtopic.php?t=171817  

* Anti-rpi

    https://www.fsf.org/resources/hw/single-board-computers  
    https://wiki.debian.org/RaspberryPi/  

    Limitations
    
    - no real time clock
    - 1.2A current limit for all USB plugs
    - slow SD controller (40 MB/s)
    - incompatible usb to sata controllers


<!--

#### Old raspi docs

* Compton

    https://www.youtube.com/watch?v=3esPpe-fclI  
    https://gist.github.com/kelleyk/6beba22586ac0c40aa30  
    
    ```
    compton --backend glx --unredir-if-possible --vsync opengl-swc
    compton --backend glx --vsync opengl-swc
    ```

* Firefox
    
    https://forums.raspberrypi.com/viewtopic.php?t=336756#p2015599  
    https://forum.manjaro.org/t/new-mesa-drivers/39735  
    https://forum.manjaro.org/t/firefox-webrender-pi4-400/63702  

* Firefox Webrender

	https://www.google.com/search?q=raspberry+pi+webrender  
	https://bugzilla.mozilla.org/show_bug.cgi?id=1663285  
	https://forum.manjaro.org/t/firefox-webrender-pi4-400/63702  
		
	https://forums.raspberrypi.com/search.php?keywords=webrender  

	https://www.google.com/search?q=raspberry+pi+firefox+webrender  

	https://bugzilla.mozilla.org/show_bug.cgi?id=1663285  

	```
	gfx.webrender.all to true
	Run 'MOZ_X11_EGL=1 firefox' in terminal
	```
	
	https://bugzilla.mozilla.org/show_bug.cgi?id=1725624  

	https://bugs.launchpad.net/ubuntu/+source/firefox/+bug/1930982  

* Chromium/Youtube audio choppy with Bullseye and KMS driver

    https://forums.raspberrypi.com/viewtopic.php?p=1945157#p1935815  

* Chromium 88 HW
    
    https://forums.raspberrypi.com/viewtopic.php?t=319304  

* RPi4 HW Acceleration
    
    https://forums.raspberrypi.com/viewtopic.php?t=325586  

-->


