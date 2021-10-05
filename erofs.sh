#!/bin/bash

PARTITION=$1
EXTRAOPT=$2

NEWIMAGE=$PARTITION_ext4.img

usage() {
    echo "sudo ./$0 <partition name>"
}

if [[ $1 == "" ]]; then 
    usage
fi

mount() {
    mkdir $PARTITION
    echo "Mounting $PARTITION..."
    sudo mount -t erofs -o loop $PARTITION.img $PARTITION 
}

rebuild() {
    mkdir tmp
    echo "Rebuilding $PARTITION as ext4 image..."
    cp -fpr $(sudo find | grep plat_file_contexts) tmp/
    sudo tools/mkuserimg_mke2fs.py "$PARTITION/" "$NEWIMAGE" ext4 "/" 4096M tmp/plat_file_contexts -j "0" -T "1230768000" -L "/" -I "256" -M "/" -m "0"
    sudo umount -f -l $PARTITION
    rm -rf $PARTITION/
}

if [[ $2 == "-m" ]]; then # mount only
    mount
else
    mount
    rebuild
fi