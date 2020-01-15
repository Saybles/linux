#!/bin/bash

source_dir=$1
destination_dir=$2
# max_copies_count=10


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

get_date_postfix() {
    printf "%s_%s" `date '+%Y%m%d'` `date '+%H%M%S'`
}

get_count_postfix() {
    echo "0"
}

update_count_postfixes() {
    dir=$1
    name=$2
    limit=$3

    i=`find $dir -regextype posix-awk -regex ".*${name}_[0-9]{1,100}.tar.gz" | sort -r | wc -l`
    for file in `find $dir -regextype posix-awk -regex ".*${name}_[0-9]{1,100}.tar.gz" | sort -r`; do
        move_to=$(printf "%s/%s_%s.tar.gz" $(dirname $file) $name $i )
        echo $file >> chk.txt
        echo $move_to >> chk.txt
        mv $file $move_to
        (( i=i-1 ))
    done
}

remove_redundant_copies() {
    dir=$1
    name=$2
    limit=$3

    i=1
    for file in `find $dir -regextype posix-awk -regex ".*${name}_[0-9]{1,100}.tar.gz" | sort`; do
        if [ $i -ge $limit ]; then
            rm $file
        fi
        (( i=i+1 ))
    done
}

compress_dir() {
    dir_to_compress=$1
    pfix=$2
    # echo "${dir_to_compress}_${pfix}.tar.gz"
    # echo  $dir_to_compress

    tar -zcvf "${dir_to_compress}_${pfix}.tar.gz" $dir_to_compress
}

complete_move() {
    src_path=$1
    dest_path=$2
    echo $src_path
    echo $dest_path

    mv $src_path $dest_path
}

complete_action() {
    read -p "Choose postfix type(1 for YYMMDD_HHSS | 2 for counter): " postfix_type
    case $postfix_type in
            1)  postfix=$(get_date_postfix)
                compress_dir $source_dir $postfix
                complete_move "${source_dir}_${postfix}.tar.gz" $destination_dir
                ;;
            2)  read -p "Enter max copies count: " max_copies_count
                postfix=$(get_count_postfix)
                compress_dir $source_dir $postfix
                update_count_postfixes $destination_dir `basename $source_dir` $max_copies_count
                remove_redundant_copies $destination_dir `basename $source_dir` $max_copies_count
                complete_move "${source_dir}_${postfix}.tar.gz" $destination_dir
                ;;
            *)  echo 'Incorrect input.'; exit 0
                ;;
        esac
}


paths_status=$(check_paths $source_dir $destination_dir)
disk_status=$(check_paths $source_dir $destination_dir)


if [ $paths_status == 'ok' ]; then
    if [ $disk_status == 'ok' ]; then
        complete_action
    else
        read -p "Not enougth space on destination disk(С or Y to continue anyway | N or A to break):" choice

        case $choice in
        C|Y) complete_action
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
