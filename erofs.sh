#!/bin/bash

PARTITION=$1
EXTRAOPT=$2

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
    # TBC    
}

if [[ $2 == "-m" ]]; then # mount only
    mount
else
    mount
    # rebuild
fi