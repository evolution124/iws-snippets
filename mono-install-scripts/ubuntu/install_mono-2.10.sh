#!/bin/bash -e

TOPDIR=$(pwd)
BUILDDIR=$TOPDIR/build
PREFIX=/opt/mono-2.10

export PATH=$PREFIX/bin:$PATH
export PKG_CONFIG_PATH=$PREFIX/lib/pkgconfig:$PKG_CONFIG_PATH
export LD_LIBRARY_PATH=$PREFIX/lib:$LD_LIBRARY_PATH


echo "updating existing system"
sudo apt-get update
sudo apt-get upgrade -y

echo "installing prerequisites"
sudo apt-get install -y build-essential libc6-dev g++ gcc libglib2.0-dev pkg-config git-core apache2 apache2-threaded-dev bison gettext autoconf automake libtool libpango1.0-dev libatk1.0-dev libgtk2.0-dev libtiff4-dev libgif-dev libglade2-dev

mkdir -p $BUILDDIR

echo
echo "downloading mono packages"
echo

cd $BUILDDIR

PACKAGES=("mono-2.10.4"
"libgdiplus-2.10"
"gtk-sharp-2.12.11"
"xsp-2.10.2"
"mod_mono-2.10")

URLS=("http://download.mono-project.com/sources/mono/mono-2.10.4.tar.bz2"
"http://download.mono-project.com/sources/libgdiplus/libgdiplus-2.10.tar.bz2"
"http://download.mono-project.com/sources/gtk-sharp212/gtk-sharp-2.12.11.tar.bz2"
"http://download.mono-project.com/sources/xsp/xsp-2.10.2.tar.bz2"
"http://ftp.novell.com/pub/mono/sources/mod_mono/mod_mono-2.10.tar.bz2")


echo Downloading
count=${#PACKAGES[@]}
index=0
while [ "$index" -lt "$count" ]
do
	#only download it if you don't already have it. 
	if [ ! -f "${PACKAGES[$index]}.tar" ]
	then
		wget -O "${PACKAGES[$index]}.tar.bz2" "${URLS[@]:$index:1}"
	fi
	if [ -f "${PACKAGES[$index]}.tar.bz2" ]
	then
		bunzip2 -df "${PACKAGES[$index]}.tar.bz2"
	fi
	if [ -f "${PACKAGES[$index]}.tar" ]
	then
		tar -xvf "${PACKAGES[$index]}.tar"
	fi
	
	let "index = $index + 1"
done


echo
echo "building mono packages"
echo

for i in "${PACKAGES[@]}"
do
	cd $BUILDDIR/$i
	./configure --prefix=$PREFIX
	make
	
	if [ "$i" = ${PACKAGES[0]} ]
	then
		sudo make install
	fi
done

echo
echo "installing mono packages"
echo

for i in "${PACKAGES[@]:1}"
do
	cd $BUILDDIR/$i
	sudo make install
done

cd $BUILDDIR
echo
echo "done"


