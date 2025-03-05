<link href="style.css" rel="stylesheet"></link>

## Readme

---

#### Labwc
    
    https://labwc.github.io/getting-started.html  
    https://wiki.archlinux.org/title/Labwc  


#### Manual configuration

* User dirs
	
	update : `~/.config/user-dirs.locale`
	
	and : `~/.config/user-dirs.dirs`
	
	```
	XDG_DESKTOP_DIR="$HOME/Bureau"
	XDG_DOWNLOAD_DIR="$HOME/Downloads"
	XDG_TEMPLATES_DIR="$HOME/.templates
	XDG_PUBLICSHARE_DIR="$HOME"
	XDG_DOCUMENTS_DIR="$HOME"
	XDG_MUSIC_DIR="$HOME"
	XDG_PICTURES_DIR="$HOME"
	XDG_VIDEOS_DIR="$HOME"
	```

* Disable smartmontools
	
	```
	sudo systemctl stop smartmontools
	sudo systemctl disable smartmontools
	```

* Avoid keyring password
    
    https://unix.stackexchange.com/questions/324843/  
    
    `mv ~/.local/share/keyrings ~/.local/share/keyrings.bak`
    
    Restart Chrome
    
    When prompted to create a keyring, continue without entering a password. (Turns out you would have been okay if you did this the first time.)

* num lock
	
	xfconf-query --create -c keyboards -p '/Default/Numlock' -t 'bool' -s 'true'
	
* labwc-tweak-gtk

    https://github.com/labwc/labwc-tweaks-gtk  
    
    ```
    git clone https://github.com/labwc/labwc-tweaks-gtk.git
    cd labwc-tweaks-gtk
    meson setup build
    meson compile -C build
    sudo meson install -C build
    ```


