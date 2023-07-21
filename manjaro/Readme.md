#### Manual configuration

- configure task bar

- configure file manager

- upgrade

    https://itsfoss.com/update-arch-linux/

    `sudo pacman -Syu`

- Configure hotkeys

    ```
    firefox             Super+B
    rofi -show run      Super+Space
    systemctl poweroff  Maj+Super+Q
    systemctl reboot    Maj+Super+R
    xfce4-taskmanager   Super+S
    xfce4-terminal      Super+T 
    ```

- Git
    
    ```
    git config --global user.name "John Doe"
    git config --global user.email johndoe@example.com
    ```

- libtinyc

    ```
    meson setup build --prefix /usr -Dbuildtype=debug
    ninja -C build
    sudo ninja -C build install
    ```


