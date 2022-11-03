

#### References

https://forums.raspberrypi.com/search.php?search_id=newposts \
https://www.raspberrypi.com/documentation/ \
https://github.com/orgs/raspberrypi/repositories \
https://github.com/orgs/raspberrypi-ui/repositories \
https://github.com/orgs/RPi-Distro/repositories \
https://downloads.raspberrypi.org/raspios_arm64/images/ \
https://forums.raspberrypi.com/viewtopic.php?t=327539 \
https://github.com/WiringPi \
https://wiki.debian.org/RaspberryPi/ \
https://www.fsf.org/resources/hw/single-board-computers \
https://github.com/librerpi/rpi-open-firmware

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

```/etc/xdg/menus/lxde-pi-applications.menu```

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


