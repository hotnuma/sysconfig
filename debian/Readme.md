
-------------------------------------------------------------------------------

- configure hotkeys

	```
	firefox				Super+B
	rofi -show run		Super+Space
	systemctl poweroff	Maj+Super+Q
	systemctl reboot	Maj+Super+R
	thunar				Super+E
	xfce4-taskmanager	Super+S
	xfce4-terminal		Super+T	
	```

- use xfce4-terminal instead of x-terminal-emulator
- configure thunar
- configure panel
- disable startup programs
- don't save session, delete saved sessions
- install ublock origin
- restore bookmarks
- download and run install script

- session
	
	https://docs.xfce.org/xfce/xfce4-session/advanced#ssh_and_gpg_agents  

-------------------------------------------------------------------------------

- Hide grub menu

    https://askubuntu.com/questions/18775/

    Open the /etc/default/grub file
    Change GRUB_TIMEOUT=10 to GRUB_TIMEOUT=0
    Save the file and quit the text editor.
    Run: sudo update-grub
    Reboot.

-------------------------------------------------------------------------------

- Intel

    https://www.dedoimedo.com/computers/linux-intel-graphics-video-tearing.html

    `/etc/X11/xorg.conf.d/20-intel.conf`

    ```
    Section "Device"
        Identifier "Intel Graphics"
        Driver "intel"
        Option "TearFree"    "true"
    EndSection
    ```

- Terminal colors
    
    https://forum.xfce.org/viewtopic.php?id=14432  



-------------------------------------------------------------------------------
#### Firefox

https://wiki.debian.org/Firefox#Hardware_Video_Acceleration  
https://wiki.debian.org/HardwareVideoAcceleration  

i965-va-driver already installed

Intel -- Mesa Intel(R) HD Graphics 520 (SKL GT2)

    gfx.webrender.all
    gfx.webrender.enabled


- Firefox config

	`about:config`

	```
	browser.sessionstore.resume_from_crash false
	layers.acceleration.force-enabled true
	layers.gpu-process.enabled true
	media.gpu-process-decoder true
	```
	
user_pref("gfx.blacklist.webrender", 4);
user_pref("gfx.blacklist.webrender.failureid", "FEATURE_FAILURE_DDX_INTEL");

-------------------------------------------------------------------------------

Error message

```
platform MSFT0101:00: failed to claim resource 1
acpi MSFT0101:00: platform device creation failed: -16
```

disable TPM ?

-------------------------------------------------------------------------------

Drivers infos

```
glxinfo|egrep "OpenGL vendor|OpenGL renderer"
OpenGL vendor string: Intel
OpenGL renderer string: Mesa Intel(R) HD Graphics 520 (SKL GT2)
```

```
sudo lspci -k | grep -EA3 'VGA|3D|Display'
00:02.0 VGA compatible controller: Intel Corporation Skylake GT2 [HD Graphics 520] (rev 07)
        Subsystem: Acer Incorporated [ALI] Skylake GT2 [HD Graphics 520]
        Kernel driver in use: i915
        Kernel modules: i915
--
01:00.0 3D controller: NVIDIA Corporation GM108M [GeForce 940MX] (rev a2)
        Subsystem: Acer Incorporated [ALI] GM108M [GeForce 940MX]
        Kernel driver in use: nouveau
        Kernel modules: nouveau
```


