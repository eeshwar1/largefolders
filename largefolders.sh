#!/bin/bash

NUM_ITEMS=30
NUM_LEVELS=3
CURRENT_LEVEL=1

# Customary usage Functions
usage() {
    echo "usage: largefolders.sh path [[[-l]]"
}

# Process command line options

FOLDER_PATH=$1
shift

while [ "$1" != "" ]; do
    case $1 in
        -l | --levels ) 
            NUM_LEVELS=$2
        shift 2;;
        * ) usage
            exit 1
    esac
done

echo "largefolders.sh - find LARGE folders"
echo "Looking in $FOLDER_PATH..."
echo "Levels: $NUM_LEVELS"

find_large_folders() 
{

    local _folder=$1
    local _current_level=$2

    _opsizelist=$(du -skh $_folder/* | sort -hr | head -$NUM_ITEMS | awk '{printf "%s,",$1}')
    _opfolderlist=$(du -skh $_folder/* | sort -hr | head -$NUM_ITEMS | awk '{printf "%s,",$2}')

    OIFS="$IFS"
    IFS=','
    read -r -a _op_size_list <<< "$_opsizelist"
    read -r -a _op_folder_list <<< "$_opfolderlist"
    IFS="$OIFS"

    ((_current_level=_current_level+1))

    _pre_str=''
    for ((_l=0; _l<_current_level; ++_l));
    do
        _pre_str="$_pre_str---"
    done
    _pre_str="$_pre_str>"

    for _i in ${!_op_folder_list[@]}
    do
        if [ -d "${_op_folder_list[$_i]}" ]; then
            
            echo "$_pre_str ${_op_size_list[$_i]}  >>> ${_op_folder_list[$_i]}"
            if [ $NUM_LEVELS -gt $_current_level ]; then
                if [ $(ls ${_op_folder_list[$_i]} | wc -l) -gt 0 ]; then
                    find_large_folders "${_op_folder_list[$_i]}" "$_current_level"
                fi
            fi
        fi
    done
}

function is_empty {
 [ "$1/"* "" = "" ]  2> /dev/null &&
 [ "$1/"..?* "" = "" ]  2> /dev/null &&
 [ "$1/".[^.]* "" = "" ]  2> /dev/null ||
 [ "$1/"* = "$1/*" ]  2> /dev/null && [ ! -e "$1/*" ] &&
 [ "$1/".[^.]* = "$1/.[^.]*" ]  2> /dev/null && [ ! -e "$1/.[^.]*" ] &&
 [ "$1/"..?* = "$1/..?*" ]  2> /dev/null && [ ! -e "$1/..?*" ]
}

opsizelist=$(du -skh $FOLDER_PATH* | sort -hr | head -$NUM_ITEMS | awk '{printf "%s,",$1}')
opfolderlist=$(du -skh $FOLDER_PATH* | sort -hr | head -$NUM_ITEMS | awk '{printf "%s,",$2}')

OIFS="$IFS"
IFS=','
read -r -a op_size_list <<< "$opsizelist"
read -r -a op_folder_list <<< "$opfolderlist"
IFS="$OIFS"
echo "count -> ${#op_folder_list[*]}"


# for i in ${!op_folder_list[@]}
# do
#     echo "[$i] ${op_folder_list[$i]}"

# done

# exit 0

# op_size_list=(${opsizelist//\n/})
# op_folder_list=(${opfolderlist//\n/})

for i in ${!op_folder_list[@]}
do
    # echo "!! ${op_folder_list[$i]} !!"
    if [ -d "${op_folder_list[$i]}" ]; then
        echo "---> ${op_size_list[$i]}  >>> ${op_folder_list[$i]}"
        if [ $NUM_LEVELS -gt $CURRENT_LEVEL ]; then
            if [ $(ls ${op_folder_list[$i]} | wc -l) -gt 0 ]; then
                find_large_folders "${op_folder_list[$i]}" "$CURRENT_LEVEL"
            fi
        fi
    fi
done

