#### Manjaro

* References
    
    https://forum.manjaro.org/tag/raspberry-pi-4  
    https://forum.manjaro.org/t/arm-stable-update-2021-12-13-firefox-kde-gear-thunderbird-libreoffice-icu-and-kernels/94518  

    https://forum.manjaro.org/t/additional-arm-packages/10132  
    https://gitlab.manjaro.org/manjaro-arm  

* bcrm_patchram_plus

    https://forum.manjaro.org/t/bcrm-patchram-plus-at-100-cpu-utilization/51035/4

    ```
    sudo systemctl disable attach-bluetooth.service
    sudo chmod 000 /usr/bin/brcm_patchram_plus
    ```

* Vivaldi

    https://help.vivaldi.com/fr/desktop-fr/install-update-fr/raspberry-pi-astuces-pour-utiliser-vivaldi/

    ```
    wget https://downloads.vivaldi.com/snapshot/install-vivaldi.sh
    sh install-vivaldi.sh
    ```

* LXDE profiles and settings

    https://forum.manjaro.org/t/lxde-lxqt-openbox-community-iso/77471  
    [https://gitlab.manjaro.org/profiles-and-settings/](https://gitlab.manjaro.org/profiles-and-settings/iso-profiles/-/blob/master/community/lxde/Packages-Desktop)

* Brcm patchram plus
    
    https://forum.manjaro.org/t/arm-testing-update-2020-11-16-bitwarden-mesa-git-pacman-and-kernels/37996/19  
    https://forum.manjaro.org/t/brcm-patchram-plus-conflict-with-pi-bluetooth/37935

* Mpv
    
    https://forum.manjaro.org/t/possible-rpi-mpv-hwdec-v4l2m2m-copy-solution/96636
    
* Manjaro update error 

    ```
    error: failed to commit transaction (conflicting files)
    rpi4-post-install: /etc/udev/rules.d/99-vcio-rewrite.rules exists in filesystem
    ```
    fix
    ```
    sudo pacman -Syu --overwrite /etc/udev/rules.d/99-vcio-rewrite.rules
    ```


