#!/bin/bash

IMAGE=$(realpath $1)
PARTITION=$2
EXTRAOPT=$3

NEWIMAGE=$PARTITION_ext4.img
LOCALDIR=`cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd`
toolsdir="$LOCALDIR/tools"
tmpdir="$LOCALDIR/tmp"

usage() {
    echo "sudo ./$0 <image path> <partition name>"
}

if [[ $1 == "" ]]; then 
    usage
fi

mount() {
    sudo rm -rf $tmpdir
    mkdir $PARTITION
    echo "Mounting $PARTITION..."
    sudo mount -t erofs -o loop $IMAGE $PARTITION 
}

rebuild() {
    mkdir $tmpdir
    echo "Rebuilding $PARTITION as ext4 image..."
    cp -fpr $(sudo find | grep plat_file_contexts) $tmpdir
    imagesize=`du -sk $PARTITION | awk '{$1*=1024;$1=int($1*1.05);printf $1}'`
    sudo python $toolsdir/mkuserimg_mke2fs.py "$PARTITION/" "$NEWIMAGE" ext4 "/" $imagesize tmp/plat_file_contexts -j "0" -T "1230768000" -L "/" -I "256" -M "/" -m "0"
    sudo umount -f -l $PARTITION
    rm -rf $PARTITION 
    sudo rm -rf $tmpdir
}

if [[ $3 == "-m" ]]; then # mount only
    mount
else
    mount
    rebuild
fi