#!/bin/bash

IMAGE=$(realpath $1)
PARTITION=$2
EXTRAOPT=$3

NEWIMAGE=$PARTITION_ext4.img
LOCALDIR=`cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd`
MOUNTDIR="$LOCALDIR/$PARTITION"
toolsdir="$LOCALDIR/tools"
tmpdir="$LOCALDIR/tmp"
fileconts="$tmpdir/plat_file_contexts"

usage() {
    echo "sudo ./$0 <image path> <partition name>"
}

if [[ $1 == "" ]]; then 
    usage
fi

mount() {
    sudo rm -rf $tmpdir $MOUNTDIR
    mkdir $MOUNTDIR
    echo "Mounting $PARTITION..."
    sudo mount -t erofs -o loop $IMAGE $MOUNTDIR 
}

rebuild() {
    mkdir $tmpdir
    echo "Rebuilding $PARTITION as ext4 image..."
    cp -fpr $(sudo find $MOUNTDIR | grep plat_file_contexts) $tmpdir/
    imagesize=`du -sk $MOUNTDIR | awk '{$1*=1024;$1=int($1*1.05);printf $1}'`
    sudo $toolsdir/mkuserimg_mke2fs.py "$MOUNTDIR/" "$NEWIMAGE" ext4 "/" 4294967296 $fileconts -j "0" -T "1230768000" -L "/" -I "256" -M "/" -m "0"
    sudo umount -f -l $MOUNTDIR
    rm -rf $MOUNTDIR 
    sudo rm -rf $tmpdir
}

shrink() {
    e2fsck -f -y $NEWIMAGE
    resize2fs -M $NEWIMAGE
}

if [[ $3 == "-m" ]]; then # mount only
    mount
elif [[ $3 == "-dr" ]]; then # rebuild only
    mount
    rebuild
else
    mount
    rebuild
    shrink
fi