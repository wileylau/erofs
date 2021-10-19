#!/bin/bash

# oplus merger

PARTITIONS="my_carrier my_company my_engineering my_heytap my_manifest my_preload my_product my_region my_stock my_version special_preload my_bigball"
merge() {
        echo "[INFO] Merging $partition into system"
        mkdir $partition
        mount -o loop -t erofs $partition.img $partition 
        cd system
        cp -fpr ../$partition/ .
        cd ..
        umount $partition
        rm -rf $partition/
}

for partition in $PARTITIONS; do
    merge
    echo "[INFO] Done"
done