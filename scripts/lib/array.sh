#!/bin/bash

# https://askubuntu.com/questions/674333/how-to-pass-an-array-as-function-argument
# https://stackoverflow.com/questions/3685970/check-if-a-bash-array-contains-a-value
# crea un array ascoiativo a partir de un array, para comprobar si el array incluye algo o no
# (requires Bash >= 4.0):

# Check if array contains item [$1: item, $2: array name]
function inArray { 
    local needle="$1"
    local item
    shift 1
    local arrref=("$@")
    # echo "check ${needle} in ${arrref[@]}"
    for item in "${arrref[@]}"; do
        # echo "compare ${item} vs ${needle}"
        if [ "${item}" == "${needle}" ]; then
            # echo "${item} eq ${needle}"
            true
            return
            break;
        else
            continue;
        fi
    done
    # echo "${needle} not found"
    false
    return
}