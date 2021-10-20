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
        mkdir $partition >/dev/null 2>&1
        mount -o loop -t erofs $partition.img $partition  >/dev/null 2>&1
        cd system >/dev/null 2>&1
        cp -fpr ../$partition/ . >/dev/null 2>&1
        cd .. >/dev/null 2>&1
        umount -f -l $partition >/dev/null 2>&1
        rm -rf $partition/ >/dev/null 2>&1
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