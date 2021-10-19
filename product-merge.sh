#!/bin/bash

PARTITION=product
# SIZE=$1

rm -rf log.txt >> /dev/null
touch log.txt

NEWIMAGE="$PARTITION-ext4.img"
LOCALDIR=`cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd`
RUNDIR=$(realpath .)
MOUNTDIR="$LOCALDIR/$PARTITION"
toolsdir="$LOCALDIR/tools"
tmpdir="$LOCALDIR/tmp"
fileconts="$tmpdir/plat_file_contexts"
PRODUCTDIR=$LOCALDIR/product
SIZECACHE="$tmpdir/size"

echo "[INFO] Cleaning up existing build residue"
rm -rf $PRODUCTDIR

# if [[ $1 == "" ]]; then
#     SIZE=4294967296
# else
#     SIZE=$1
# fi

usage() {
    echo "sudo ./$0"
}

PARTITIONS="my_product my_engineering my_company my_carrier my_region my_heytap my_stock my_preload my_bigball my_manifest"

mkdir $PRODUCTDIR
mkdir -p $tmpdir
touch $fileconts

merge() {
        mkdir $partition
        mount -o loop -t erofs $partition.img $partition
        cp -fpr $partition/* $PRODUCTDIR/
        umount -f -l $partition
        rm -rf $partition
}

clean() {
        echo "[INFO] Cleaning product image"
        cd $PRODUCTDIR
        rm -rf apkcerts.txt
        rm -rf applist
        rm -rf build.prop
        rm -rf custom_info.txt
        rm -rf decouping_wallpaper
        rm -rf del*
        rm -rf etc
        rm -rf framework
        rm -rf lost+found
        rm -rf media
        rm -rf non_overlay
        rm -rf plugin
        rm -rf product_overlay
        rm -rf res
        rm -rf vendor
        cd $RUNDIR
}

fconts() {
        echo "[INFO] Grabbing file contexts"
        mkdir $LOCALDIR/system
        sudo mount -o loop -t erofs $RUNDIR/system.img $LOCALDIR/system
        sudo cat $LOCALDIR/system/system/etc/selinux/plat_file_contexts >> $fileconts
        sudo umount -f -l $LOCALDIR/system
        rm -rf $LOCALDIR/system
}

getsize() {
        echo "[INFO] Setting image size"
        touch $SIZECACHE
        du -sb $PRODUCTDIR >> $SIZECACHE
        SIZE=$(cut -f1 $SIZECACHE)
        echo "Image size will be $SIZE" >> log.txt
}
for partition in $PARTITIONS; do
        echo "[INFO] Merging $partition into product.img"
        merge >> log.txt
done

clean
fconts
getsize
echo "[INFO] Rebuilding Product image"
sudo $toolsdir/mkuserimg_mke2fs.py "$MOUNTDIR/" "$NEWIMAGE" ext4 "/$PARTITION" $SIZE $fileconts -j "0" -T "1230768000" -L "$PARTITION" -I "256" -M "/$PARTITION" -m "0" >> log.txt
echo "[INFO] Cleaning up"
rm -rf $PRODUCTDIR $tmpdir
