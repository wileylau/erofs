#!/bin/bash

# oplus merger

RUNDIR=$(realpath .)
prep() {
        echo "[INFO] Setting up"
        cd $RUNDIR
        mkdir system
        mount system.img system
}
PARTITIONS="my_carrier my_company my_engineering my_heytap my_manifest my_preload my_product my_region my_stock my_version my_bigball"
merge() {
        cd $RUNDIR
        echo "[INFO] Merging $partition into system"
        mkdir $partition
        mount -o loop -t erofs $partition.img $partition 
        cd system
        cp -fpr ../$partition/ .
        cd ..
        umount -f -l $partition
        rm -rf $partition/
}

clean() {
        echo "[INFO] Cleaning up"
        umount $RUNDIR/system/
        rm -rf $RUNDIR/system/
}

prep
for partition in $PARTITIONS; do
    merge
done
echo "[INFO] Done"
clean