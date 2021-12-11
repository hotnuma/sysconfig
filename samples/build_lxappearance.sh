#!/usr/bin/bash

dest=/usr/bin/automake
if [[ ! -f $dest ]]; then
	sudo apt -y install git build-essential autoconf automake intltool
fi

dest=~/DevFiles
if [[ ! -d $dest ]]; then
	mkdir $dest
fi

cd $dest

dest=~/DevFiles/lxappearance
if [[ ! -d $dest ]]; then
	git clone https://github.com/lxde/lxappearance.git
	cd $dest
	./autogen.sh
	intltoolize --force
	./configure --enable-gtk3 --enable-debug
	make
fi


