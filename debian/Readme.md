
-------------------------------------------------------------------------------

- configure hotkeys

    ```
    firefox             Super+B
    rofi -show run      Super+Space
    systemctl poweroff  Maj+Super+Q
    systemctl reboot    Maj+Super+R
    thunar              Super+E
    xfce4-taskmanager   Super+S
    xfce4-terminal      Super+T 
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

- Terminal colors
    
    https://forum.xfce.org/viewtopic.php?id=14432  

-------------------------------------------------------------------------------

- Hide grub menu

    https://askubuntu.com/questions/18775/

    Open the /etc/default/grub file
    Change GRUB_TIMEOUT=10 to GRUB_TIMEOUT=0
    Save the file and quit the text editor.
    Run: sudo update-grub
    Reboot.

-------------------------------------------------------------------------------

- Intel GPU
    
    https://bugzilla.mozilla.org/show_bug.cgi?id=1710400  
    
    `sudo apt remove xserver-xorg-video-intel`

- Firefox
    
    check webrender : type `about:support` in the address bar.

    In `about:config` :

    ```
    browser.sessionstore.resume_from_crash false
    ```

-------------------------------------------------------------------------------

- Error message

    ```
    platform MSFT0101:00: failed to claim resource 1
    acpi MSFT0101:00: platform device creation failed: -16
    ```






-------------------------------------------------------------------------------

https://wiki.debian.org/Firefox#Hardware_Video_Acceleration  
https://wiki.debian.org/HardwareVideoAcceleration  

-------------------------------------------------------------------------------

#### Drivers infos

`inxi -b`

```
System:
  Host: acer Kernel: 6.1.0-9-amd64 arch: x86_64 bits: 64 Desktop: N/A
    Distro: Debian GNU/Linux 12 (bookworm)
Machine:
  Type: Laptop System: Acer product: Aspire E5-774G v: V1.25
    serial: <superuser required>
  Mobo: Acer model: Hulk_SK v: V1.25 serial: <superuser required>
    UEFI: Insyde v: 1.25 date: 03/03/2017
CPU:
  Info: dual core Intel Core i3-6006U [MT MCP] speed (MHz): avg: 1625
    min/max: 400/2000
Graphics:
  Device-1: Intel Skylake GT2 [HD Graphics 520] driver: i915 v: kernel
  Device-2: NVIDIA GM108M [GeForce 940MX] driver: nouveau v: kernel
  Display: x11 server: X.Org v: 1.21.1.7 driver: X: loaded: intel dri: iris
    gpu: i915 resolution: 1280x1024~60Hz
  API: OpenGL v: 4.6 Mesa 22.3.6 renderer: Mesa Intel HD Graphics 520 (SKL
    GT2)
Network:
  Device-1: Realtek RTL8111/8168/8411 PCI Express Gigabit Ethernet
    driver: r8169
Drives:
  Local Storage: total: 111.79 GiB used: 5.1 GiB (4.6%)
Info:
  Processes: 146 Uptime: 20m Memory: 7.63 GiB used: 1.39 GiB (18.2%)
  Shell: Bash inxi: 3.3.26
```

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


