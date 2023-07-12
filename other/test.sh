#!/usr/bin/bash

systemctl -q is-enabled dhcpcd > /dev/null 2>&1
DHENABLED=$?

if [ "$INTERACTIVE" = True ]; then
DEFAULT=1
if [ "$NMENABLED" = 0 ] ; then
DEFAULT=2
fi
if is_installed dhcpcd5 ; then
OPTIONS="1 dhcpcd"
fi
if is_installed network-manager ; then
OPTIONS="$OPTIONS 2 NetworkManager"
fi
#shellcheck disable=2086
NMOPT=$(whiptail --menu "Select the network configuration to use" 20 60 10 $OPTIONS --default-item "$DEFAULT" 3>&1 1>&2 2>&3)
RET="$?"
else
NMOPT="$1"
RET=0
fi
if [ "$RET" -ne 0 ] ; then
return
fi

if [ "$NMOPT" -eq 2 ] ; then # NetworkManager selected
ENABLE_SERVICE=NetworkManager
DISABLE_SERVICE=dhcpcd
NETCON="NetworkManager"
else # dhcpcd selected
ENABLE_SERVICE=dhcpcd
DISABLE_SERVICE=NetworkManager
NETCON="dhcpcd"
fi

systemctl -q disable "$DISABLE_SERVICE" 2> /dev/null
systemctl -q enable "$ENABLE_SERVICE"
if [ "$INIT" = "systemd" ]; then
systemctl -q stop "$DISABLE_SERVICE" 2> /dev/null
systemctl -q --no-block start "$ENABLE_SERVICE"
fi
ASK_TO_REBOOT=1
if [ "$INTERACTIVE" = True ]; then
whiptail --msgbox "$NETCON is active" 20 60 1
fi


