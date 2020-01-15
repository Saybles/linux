#!/bin/bash

source_dir=$1
destination_dir=$2
# max_copies_count=10


check_paths() {
    src_path=$1
    dest_path=$2

    if [ $src_path = $dest_path ]; then
        status='bad'
    elif [ $(dirname $src_path) = $dest_path ] ||
         [ $(dirname $dest_path) = $src_path ]; then
        status='bad'
    else
        status='ok'
    fi

    echo $status
    echo "paths check:" >> "out_${log_postfix}.log"
    echo "    paths: ${src_path} => ${dest_path}; check_status: $status" >> "out_${log_postfix}.log"
}

check_disk() {
    src_path=$1
    dest_path=$2
    
    # kbytes
    needed_space=$( du -k  $src_path | tail -1 | tr -dc 0-9 )
    available_space=$( df -k $dest_path | awk 'NR == 2 {print $4}' )

    if [ $needed_space -lt $available_space ]; then
        status='ok'
    else
        status='bad'
    fi

    echo $status
    echo "disk check:" >> "out_${log_postfix}.log"
    echo "    paths: ${src_path} => ${dest_path}; disk_status: $status" >> "out_${log_postfix}.log"
}

get_date_postfix() {
    postfix=$("%s_%s" `date '+%Y%m%d'` `date '+%H%M%S'`)
    echo $postfix
    echo "date postfix recieved: ${postfix}" >> "out_${log_postfix}.log"
}

get_count_postfix() {
    postfix=0
    echo $postfix
    echo "count postfix recieved: ${postfix}" >> "out_${log_postfix}.log"
}

get_log_postfix() {
    printf "%s_%s" `date '+%Y%m%d'` `date '+%H%M%S'`
}

update_count_postfixes() {
    dir=$1
    name=$2
    limit=$3

    i=`find $dir -regextype posix-awk -regex ".*${name}_[0-9]{1,100}.tar.gz" | sort -r | wc -l`
    for file in `find $dir -regextype posix-awk -regex ".*${name}_[0-9]{1,100}.tar.gz" | sort -r`; do
        move_to=$(printf "%s/%s_%s.tar.gz" $(dirname $file) $name $i )
        mv $file $move_to
        (( i=i-1 ))
    done

    echo "count postfixes for ${name} in ${dir} updated" >> "out_${log_postfix}.log"
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

    echo "redundand copies for ${name} in ${dir} removed" >> "out_${log_postfix}.log"
}

compress_dir() {
    dir_to_compress=$1
    pfix=$2

    tar -zcvf "${dir_to_compress}_${pfix}.tar.gz" $dir_to_compress

    echo "compression completed:" >> "out_${log_postfix}.log"
    echo "${dir_to_compress} => ${dir_to_compress}_${pfix}.tar.gz" >> "out_${log_postfix}.log"
}

complete_move() {
    src_path=$1
    dest_path=$2

    mv $src_path $dest_path
    echo "move completed:" >> "out_${log_postfix}.log"
    echo "${src_path} => ${dest_path}" >> "out_${log_postfix}.log"
}

complete_action() {
    read -p "Choose postfix type(1 for YYMMDD_HHSS | 2 for counter): " postfix_type
    case $postfix_type in
            1)  echo "postfix type set to 1(YYMMDD_HHSS)" >> "out_${log_postfix}.log"
                postfix=$(get_date_postfix)
                compress_dir $source_dir $postfix
                complete_move "${source_dir}_${postfix}.tar.gz" $destination_dir
                ;;
            2)  echo "postfix type set to 2(counter)" >> "out_${log_postfix}.log"
                read -p "Enter max copies count: " max_copies_count
                echo "max_copies_count set to: ${max_copies_count}" >> "out_${log_postfix}.log"
                postfix=$(get_count_postfix)
                compress_dir $source_dir $postfix
                update_count_postfixes $destination_dir $source_dir $max_copies_count
                remove_redundant_copies $destination_dir $source_dir $max_copies_count
                complete_move "${source_dir}_${postfix}.tar.gz" $destination_dir
                ;;
            *)  echo "wrong user input; exit code 0" >> "out_${log_postfix}.log"
                echo 'Incorrect input.'; exit 0
                ;;
        esac
}

log_postfix=$(get_log_postfix)
touch "out_${log_postfix}.log"
echo "run started; date code: ${log_postfix}; run dir: $(pwd)" >> "out_${log_postfix}.log"

paths_status=$(check_paths $source_dir $destination_dir)
disk_status=$(check_paths $source_dir $destination_dir)

if [ $paths_status == 'ok' ]; then
    if [ $disk_status == 'ok' ]; then
        complete_action
    else
        read -p "Not enougth space on destination disk(С or Y to continue anyway | N or A to break):" choice

        case $choice in
        C|Y) echo "performing move anyway..." >> "out_${log_postfix}.log" 
             complete_action
             ;;
        N|A) echo "canceling move..." >> "out_${log_postfix}.log" 
             exit 0
             ;;
        *)   echo "wrong user input; exit code 0" >> "out_${log_postfix}.log"
             echo 'Incorrect input.'; exit 0
             ;;
    esac
    fi
else
    echo "wrong paths; exit code 0" >> "out_${log_postfix}.log"
    echo "Incorrect paths of directories."; exit 0
fi

echo "-----------------------------------------------------------" >> "out_${log_postfix}.log"
