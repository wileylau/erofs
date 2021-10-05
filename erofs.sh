#!/bin/bash

IMAGE=$(realpath $1)
PARTITION=$2
EXTRAOPT=$3

NEWIMAGE="$PARTITION-ext4.img"
LOCALDIR=`cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd`
RUNDIR=$(realpath .)
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

contextfix() {
    mkdir system
    sudo mount -o 
    echo "/my_bigball                    u:object_r:rootfs:s0" >> "$fileconts"
    echo "/my_carrier                    u:object_r:rootfs:s0" >> "$fileconts"
    echo "/my_company                    u:object_r:rootfs:s0" >> "$fileconts"
    echo "/my_engineering                u:object_r:rootfs:s0" >> "$fileconts"
    echo "/my_heytap                     u:object_r:rootfs:s0" >> "$fileconts"
    echo "/my_manifest                   u:object_r:rootfs:s0" >> "$fileconts"
    echo "/my_preload                    u:object_r:rootfs:s0" >> "$fileconts"
    echo "/my_product                    u:object_r:rootfs:s0" >> "$fileconts"
    echo "/my_region                     u:object_r:rootfs:s0" >> "$fileconts"
    echo "/my_stock                      u:object_r:rootfs:s0" >> "$fileconts"
    echo "/my_version                    u:object_r:rootfs:s0" >> "$fileconts"
    echo "/special_preload               u:object_r:rootfs:s0" >> "$fileconts"
    if [[ $PARTITION != "system" ]]; then
        mkdir $RUNDIR/system
        sudo mount -o loop -t erofs $RUNDIR/system.img $RUNDIR/system
        sudo cat $(sudo find $RUNDIR | grep file_contexts) >> $fileconts >> /dev/null
        sudo umount -f -l $RUNDIR/system
        rm -rf $RUNDIR/system
    fi
}

rebuild() {
    mkdir $tmpdir
    echo "Rebuilding $PARTITION as ext4 image..."
    cp -fpr $(sudo find $MOUNTDIR | grep file_contexts) $tmpdir/
    contextfix
    imagesize=`du -sk $MOUNTDIR | awk '{$1*=1024;$1=int($1*1.05);printf $1}'`
    if [[ $PARTITION == "system" ]]; then
        sudo $toolsdir/mkuserimg_mke2fs.py "$MOUNTDIR/" "$NEWIMAGE" ext4 "/" 4294967296 $fileconts -j "0" -T "1230768000" -L "/" -I "256" -M "/" -m "0"
    else
        sudo $toolsdir/mkuserimg_mke2fs.py "$MOUNTDIR/" "$NEWIMAGE" ext4 "/$PARTITION" 4294967296 $fileconts -j "0" -T "1230768000" -L "$PARTITION" -I "256" -M "/$PARTITION" -m "0"
    fi
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