#!/bin/bash

rand_str() {
    min_len=$1
    max_len=$2

    head /dev/urandom | tr -dc A-Za-z0-9 | head -c $(( (RANDOM % $max_len) + $min_len))
    echo ''
}

g_folder_structure() {
    current_depth=$2

    if [[ $current_depth -lt $final_depth ]]; then
        current_dir=$1
        folders_count=$(( RANDOM % $max_iter))
        files_count=$(( $max_iter - $folders_count ))

        cd $current_dir

        for ((i=0; i<$files_count; i++)) {
            filename=$(rand_str $min_name_len $max_name_len)
            echo $(rand_str $min_file_size $max_file_size) >> "${filename}.txt"
        }

        for (( i=0; i<$folders_count; i++ )) {
            foldername=$(rand_str 1 8)
            mkdir ${foldername}
        }

        next_depth=$(( current_depth + 1 ))

        for d in */; do
            $(g_folder_structure $d $next_depth)
        done
    fi
}


################################################################################
initial_dir=$1
final_depth=$2

min_name_len=1
max_name_len=8

min_file_size=1
max_file_size=$3

max_iter=$4


################################################################################
rm -rf $initial_dir
mkdir -p $initial_dir

g_folder_structure $initial_dir 0 2>/dev/null