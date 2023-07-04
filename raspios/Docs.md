

#### References

https://forums.raspberrypi.com/search.php?search_id=newposts  
https://www.raspberrypi.com/documentation/  
https://github.com/orgs/raspberrypi/repositories  
https://github.com/orgs/raspberrypi-ui/repositories  
https://github.com/orgs/RPi-Distro/repositories  
https://downloads.raspberrypi.org/raspios_arm64/images/  
https://forums.raspberrypi.com/viewtopic.php?t=327539  
https://github.com/WiringPi  
https://wiki.debian.org/RaspberryPi/  
https://www.fsf.org/resources/hw/single-board-computers  
https://github.com/librerpi/rpi-open-firmware  

* Install XFCE
    
    https://raspberrytips.fr/meilleurs-logiciels-raspberry-pi/  


#### System informations

* Read kernel and firmware version :

    ```
    uname -a && vcgencmd version
    ```

* Read CPU temperature

    ```
    vcgencmd measure_temp
    ```

* Release notes : 
    
    https://downloads.raspberrypi.org/raspios_armhf/release_notes.txt


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

`lightdm --show-config`

lightdm : /etc/lightdm/lightdm.conf

```ini
[LightDM]

[Seat:*]
greeter-session=pi-greeter
greeter-hide-users=false
display-setup-script=/usr/share/dispsetup.sh
autologin-user=pi

[XDMCPServer]
[VNCServer]
```

default session : 

~/.dmrc

```ini
[Desktop]
Session=lightdm-xsession
```

/usr/share/xsessions/lightdm-xsession.desktop

```ini
[Desktop Entry]
Version=1.0
Name=Default Xsession
Exec=default
Icon=
Type=Application
```

default session :

https://askubuntu.com/questions/77191/how-can-i-use-lightdm-for-user-defined-sessions

_The Name entry is what lightdm would display for this session. The Exec entry is the important thing, and it should be the name of the program that starts the actual session. When you log in, lightdm calls the /etc/X11/Xsession script, passing it the value of Exec as an argument, and Xsession will, eventually, execute this program (for example, it could be startxfce4 for starting a xfce4 session). If the Exec entry is the special string default, then Xsession will execute the user's ~/.xsession file. (Xsession would also execute ~/.xsession if it's called without arguments.)_

DESKTOP_SESSION=LXDE-pi

startup script : /usr/bin/startlxde-pi


#### Application menu

`/etc/xdg/menus/lxde-pi-applications.menu`


#### Openbox

openbox is set in `~/config/lxsession/LXDE-pi/desktop.conf` using a wrapper script.

```cat /usr/bin/openbox-lxde-pi 
#!/bin/sh
exec openbox --config-file $XDG_CONFIG_HOME/openbox/lxde-pi-rc.xml $@
```

The default config file should be `/home/pi/.config/openbox/lxde-pi-rc.xml` but it's possible to set openbox in `desktop.conf` and use `/home/pi/.config/openbox/rc.xml`

```ini
[Session]
window_manager=openbox
```

* Reload openbox config :

    ```
    openbox --reconfigure
    ```


#### Raspi configuration

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


#### Other

* Firefox
    
    https://forums.raspberrypi.com/viewtopic.php?t=336756#p2015599  


#### Bugs

* Syslog

    kernel: v3d fec00000.v3d: MMU error from client L2T  
    https://forums.raspberrypi.com/viewtopic.php?t=277917  
    http://tabuas.tech/2021/05/19/pi-400-log/

* Pixel wrap bug fix

    ```
    Jun 24 2021 17:24:58 
    Copyright (c) 2012 Broadcom
    version 65aff9e0bea5b64c530db52aa4497e809fdf22c8 (clean) (release) (start)
    Linux raspberrypi 5.10.44-v8+ #1429 SMP PREEMPT Fri Jun 25 10:03:37 BST 2021 aarch64 GNU/Linux
    ```


#### Raspberry Pi

* glamor
    
    /usr/share/X11/xorg.conf.d/20-noglamor.conf

* CPU governor

    https://askubuntu.com/questions/1021748/  
    https://raspberrypi.stackexchange.com/questions/9034/  

* USB Chipset
    
    https://forums.raspberrypi.com/viewtopic.php?t=326157
    
    ```
    That's true for most of the JMS578 family of USB 3.0 bridge chips,
    but not necessarily with the 580 series USB 3.1 chips.
    I have a USB 3.1 Gen 2 enclosure with a JMS583 chip that works
    fine with Pi computers. It supports UASP in RPiOS, and TRIM works
    with a udev rule.
    ```
    
* Custom RPi images
	
	https://forums.raspberrypi.com/viewtopic.php?f=131&t=314419
	
* Custom OS
    
    https://forums.raspberrypi.com/viewtopic.php?t=327060

* XML libraries
    
    https://forums.raspberrypi.com/viewtopic.php?p=1958438#p1958438
    
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
    
* Command line piclone
    
    https://forums.raspberrypi.com/viewtopic.php?t=180383

* Default audio playback
    
    https://forums.raspberrypi.com/viewtopic.php?t=327267#p1958987
    
* C++ SSD1306 I2C LCD
    
    https://forums.raspberrypi.com/viewtopic.php?t=224984  
    https://forums.raspberrypi.com/viewtopic.php?t=171817
    
* Chromium/Youtube audio choppy with Bullseye and KMS driver

    https://forums.raspberrypi.com/viewtopic.php?p=1945157#p1935815

* RPi4 with PiOS ignore display setting in config.txt

    https://forums.raspberrypi.com/viewtopic.php?p=1945199#p1945199

* Display issue with Bullseye image and Pi 4B

    https://forums.raspberrypi.com/viewtopic.php?p=1945198#p1945198

* RPi4 HW Acceleration
    
    https://forums.raspberrypi.com/viewtopic.php?t=325586
    
* Chromium 88 HW
    
    https://forums.raspberrypi.com/viewtopic.php?t=319304

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

* references

    display settings :

    video=HDMI-1:800x480@60

    https://forums.raspberrypi.com/viewtopic.php?t=325011#p1945199

    chromium crash :

    https://forums.raspberrypi.com/viewtopic.php?t=323640&start=75#p1940502

    firefox :

    https://forum.manjaro.org/t/new-mesa-drivers/39735  
    https://forum.manjaro.org/t/firefox-webrender-pi4-400/63702

* Compton

    https://www.youtube.com/watch?v=3esPpe-fclI  
    https://gist.github.com/kelleyk/6beba22586ac0c40aa30  
    compton --backend glx --unredir-if-possible --vsync opengl-swc
    compton --backend glx --vsync opengl-swc


