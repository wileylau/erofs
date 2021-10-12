#!/bin/bash

IMAGE=$(realpath $1)
PARTITION=$2
SIZE=$3

NEWIMAGE="$PARTITION-ext4.img"
LOCALDIR=`cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd`
RUNDIR=$(dirname $1)
MOUNTDIR="$LOCALDIR/$PARTITION"
toolsdir="$LOCALDIR/tools"
tmpdir="$LOCALDIR/tmp"
fileconts="$tmpdir/plat_file_contexts"

if [[ $3 == "" ]]; then
    SIZE=4294967296
else
    SIZE=$3
fi

usage() {
    echo "sudo ./$0 <image path> <partition name>"
}

if [[ $1 == "" ]]; then 
    usage
fi

mount() {
    sudo rm -rf $tmpdir $MOUNTDIR
    mkdir $MOUNTDIR
    echo "[INFO] Mounting $PARTITION..."
    sudo mount -t erofs -o loop $IMAGE $MOUNTDIR 
}

contextfix() {
    echo "/my_bigball(/.*)?                    u:object_r:rootfs:s0" >> "$fileconts"
    echo "/my_carrier(/.*)?                    u:object_r:rootfs:s0" >> "$fileconts"
    echo "/my_company(/.*)?                    u:object_r:rootfs:s0" >> "$fileconts"
    echo "/my_engineering(/.*)?                u:object_r:rootfs:s0" >> "$fileconts"
    echo "/my_heytap(/.*)?                     u:object_r:rootfs:s0" >> "$fileconts"
    echo "/my_manifest(/.*)?                   u:object_r:rootfs:s0" >> "$fileconts"
    echo "/my_preload(/.*)?                    u:object_r:rootfs:s0" >> "$fileconts"
    echo "/my_product(/.*)?                    u:object_r:rootfs:s0" >> "$fileconts"
    echo "/my_region(/.*)?                     u:object_r:rootfs:s0" >> "$fileconts"
    echo "/my_stock(/.*)?                      u:object_r:rootfs:s0" >> "$fileconts"
    echo "/my_version(/.*)?                    u:object_r:rootfs:s0" >> "$fileconts"
    echo "/special_preload(/.*)?               u:object_r:rootfs:s0" >> "$fileconts"
    if [[ $PARTITION != "system" ]]; then
        mkdir $LOCALDIR/system
        sudo mount -o loop -t erofs $RUNDIR/system.img $LOCALDIR/system
        sudo cat $LOCALDIR/system/system/etc/selinux/plat_file_contexts >> $fileconts
        sudo umount -f -l $LOCALDIR/system
        rm -rf $LOCALDIR/system
    fi
}

rebuild() {
    mkdir $tmpdir
    echo "[INFO] Rebuilding $PARTITION as ext4 image..."
    cp -fpr $(sudo find $MOUNTDIR | grep file_contexts) $tmpdir/ >> /dev/null
    contextfix
    imagesize=`du -sk $MOUNTDIR | awk '{$1*=1024;$1=int($1*1.05);printf $1}'`
    if [[ $PARTITION == "system" ]]; then
        sudo $toolsdir/mkuserimg_mke2fs.py "$MOUNTDIR/" "$NEWIMAGE" ext4 "/" $SIZE $fileconts -j "0" -T "1230768000" -L "/" -I "256" -M "/" -m "0" >> /dev/null
    else
        sudo $toolsdir/mkuserimg_mke2fs.py "$MOUNTDIR/" "$NEWIMAGE" ext4 "/$PARTITION" $SIZE $fileconts -j "0" -T "1230768000" -L "$PARTITION" -I "256" -M "/$PARTITION" -m "0" >> /dev/null
    fi
    sudo umount -f -l $MOUNTDIR
    rm -rf $MOUNTDIR 
    sudo rm -rf $tmpdir
}

shrink() {
    e2fsck -f -y $NEWIMAGE >> /dev/null
    resize2fs -M $NEWIMAGE >> /dev/null
}

if [[ $3 == "" ]]; then
    mount
    rebuild
    shrink
else
    mount
    rebuild
fi
