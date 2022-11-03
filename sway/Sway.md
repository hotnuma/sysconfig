

#### References

https://forum.manjaro.org/latest  
https://github.com/arindas/manjarno

#### Setup

* Minimal setup
    
    https://wiki.manjaro.org/index.php/Install_Desktop_Environments
    
    https://archlinux.org/groups/x86_64/lxde-gtk3/

    https://forum.manjaro.org/t/vanilla-sway-install-login-manager/76476/5  
    https://gitlab.manjaro.org/manjaro-arm/applications/arm-profiles/-/blob/master/editions/  
    https://gitlab.manjaro.org/manjaro-arm/applications/arm-profiles/-/tree/master/overlays/
    
#### Packages

* Check if a package is installed using pacman
    
    https://stackoverflow.com/questions/22681578/  
    https://stackoverflow.com/questions/26274415/
    
    ```
    pacman -Ss mesa | grep installed
    ```

* Switchings branches
    
    https://wiki.manjaro.org/index.php/Switching_Branches
    
    Testing
    ```
    sudo pacman-mirrors -aS testing && sudo pacman -Syyu
    ```
    
    Unstable
    ```
    sudo pacman-mirrors -aS unstable && sudo pacman -Syyu
    ```
    
* Get current branch
    
    ```
    pacman-mirrors --get-branch 
    ```

* Install without confirmation
    
    https://unix.stackexchange.com/questions/52277/
    
    ```
    pacman --noconfirm -S package-name
    ```

#### Sway

https://forum.manjaro.org/t/sway-community-edition-preview/48044

* Autologin
    
    https://forum.manjaro.org/t/raspberry-pi-autologin-in-sway/43039/5  
    https://serverfault.com/questions/840996/
    
    ```
    sudo systemctl edit getty@tty1
    ```

    After line 3 copy/paste, replace ‘user’ with your user name :
    ```
    [Service]
    ExecStart=
    ExecStart=-/usr/bin/agetty --autologin user --noclear %I $TERM
    ```

    Add to your ~/.bash_profile
    ```
    if [ -z $DISPLAY ] && [ “$(tty)” = “/dev/tty1” ]; then
        exec sway
    fi
    ```

* Change keyboard layout in `~/.config/sway/config`
    
    ```
    input * {xkb_layout "fr"}
    ```


