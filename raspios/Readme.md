
#### Manual configuration

- Chromium
    
    Set Google search engine
    
- Change desktop session

    `geany ~/.dmrc`
    
    ```
    [Desktop]
    Session=custom
    #Session=xfce
    #Session=lightdm-xsession
    ```

- Terminal
    
    Increase line history to 2000  
    Incease syslog alias lines to 1000

#### Xfce Configuration

- Avoid keyring password
    
    https://unix.stackexchange.com/questions/324843/  
    
    `mv ~/.local/share/keyrings ~/.local/share/keyrings.bak`
    
    Restart Chrome
    
    When prompted to create a keyring, continue without entering a password. (Turns out you would have been okay if you did this the first time.)

- Screen tearing
    
    https://wiki.archlinux.org/title/Xfwm  
    
    `xfconf-query -c xfwm4 -p /general/vblank_mode -s glx`

- Configure hotkeys

    ```
    chromium-browser    Super+B
    fileman             Super+E
    rofi -show run      Super+Space
    systemctl poweroff  Maj+Super+Q
    systemctl reboot    Maj+Super+R
    xfce4-taskmanager   Super+S
    xfce4-terminal      Super+T 
    ```

#### Other

- Drive consumption

    Toshiba Canvio Basics : a maximum of 900mA power, even in the largest capacity version.
    
    Kingston a400 SSD : 0.195W Idle / 0.279W Avg / 0.642W (MAX) Read / 1.535W (MAX) Write


<!--
- Upgrade
    
    https://gist.github.com/jauderho/6b7d42030e264a135450ecc0ba521bd8  
    https://raspberrytips.com/update-raspberry-pi-latest-version/  

- Install previous version
    
    https://unix.stackexchange.com/questions/242014/  
    
    `sudo apt install openbox=3.6.1-9+rpt1+deb11u1`
-->

