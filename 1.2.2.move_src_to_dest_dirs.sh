#!/bin/bash

source_dir=$1
destination_dir=$2


check_paths() {
    src_path=$1
    dest_path=$2

    if [ $src_path = $dest_path ]; then
        echo 'bad'
    elif [ $(dirname $src_path) = $dest_path ] ||
         [ $(dirname $dest_path) = $src_path ]; then
        echo 'bad'
    else
        echo 'ok'
    fi
}

check_disk() {
    src_path=$1
    dest_path=$2
    
    # kbytes
    needed_space=$( du -k  $src_path | tail -1 | tr -dc 0-9 )
    available_space=$( df -k $dest_path | awk 'NR == 2 {print $4}' )

    if [ $needed_space -lt $available_space ]; then
        echo 'ok'
    else
        echo 'bad'
    fi
}

complete_move() {
    src_path=$1
    dest_path=$2

    cp -rp -R "$src_path/." $dest_path
}

paths_status=$(check_paths $source_dir $destination_dir)
disk_status=$(check_paths $source_dir $destination_dir)

if [ $paths_status == 'ok' ]; then
    if [ $disk_status == 'ok' ]; then
        complete_move $source_dir $destination_dir
    else
        read -p "Not enougth space on destination disk(С or Y to continue anyway | N or A to break):" choice

        case $choice in
        C|Y)    complete_move $source_dir $destination_dir
            ;;
        N|A) exit 0
            ;;
        *) echo 'Incorrect input.'; exit 0
            ;;
    esac
    fi
else
    echo "Incorrect paths of directories."; exit 0
fi
