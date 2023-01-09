#!/usr/bin/bash

MY_DATA_DIRS="/bla:/usr/share"
MY_CONFIG_DIRS="/bla:/ble:/etc/xdg"

case "$MY_DATA_DIRS" in
*:/usr/share | /usr/share ) : ;;
* ) MY_DATA_DIRS="$MY_DATA_DIRS:/usr/share" ;;
esac

case "$MY_CONFIG_DIRS" in
*:/etc/xdg | /etc/xdg ) : ;;
* ) MY_CONFIG_DIRS="$MY_CONFIG_DIRS:/etc/xdg" ;;
esac

echo $MY_DATA_DIRS
echo $MY_CONFIG_DIRS


