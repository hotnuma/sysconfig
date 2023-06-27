- configure thunar
- configure panel
- install ublock origin
- configure hotkeys
- download and run install script
- configure startup programs

---------------------------------------------------------

Hide grub menu

https://askubuntu.com/questions/18775/

Open the /etc/default/grub file
Change GRUB_TIMEOUT=10 to GRUB_TIMEOUT=0
Save the file and quit the text editor.
Run: sudo update-grub
Reboot.

---------------------------------------------------------
https://www.dedoimedo.com/computers/linux-intel-graphics-video-tearing.html

/etc/X11/xorg.conf.d/20-intel.conf

Section "Device"
    Identifier "Intel Graphics"
    Driver "intel"
    Option "TearFree"    "true"
EndSection

-------------------------------------------------------------------------------

Error message

platform MSFT0101:00: failed to claim resource 1
acpi MSFT0101:00: platform device creation failed: -16

disable TPM ?

-------------------------------------------------------------------------------

Drivers infos

glxinfo|egrep "OpenGL vendor|OpenGL renderer"
OpenGL vendor string: Intel
OpenGL renderer string: Mesa Intel(R) HD Graphics 520 (SKL GT2)

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


