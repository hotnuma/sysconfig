#!/usr/bin/bash

case "$XDG_DATA_DIRS" in
    *:/usr/share | /usr/share ) : ;;
    * ) XDG_DATA_DIRS="$XDG_DATA_DIRS:/usr/share" ;;
esac

echo $XDG_DATA_DIRS


