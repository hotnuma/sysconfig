#!/usr/bin/bash

#sudo apt-get update && sudo apt-get dist-upgrade

sudo sed -i -e 's/bullseye/bookworm/g' /etc/apt/sources.list
sudo sed -i -e 's/bullseye/bookworm/g' /etc/apt/sources.list.d/raspi.list
sudo apt update
sudo apt -y full-upgrade
sudo apt -y autoremove
sudo apt -y clean
sudo reboot

# remove old config files after doing sanity checks
#sudo apt purge ?config-files


