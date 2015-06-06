#!/usr/bin/env bash

function main_ls {

    local IFS=$'\n'
    local list=( `grep -nr "$PROJECT_DIR/main.sh" $BIN_DIR` )
    local alias=""
    local command=""

    echo -e ""
    echo -e " ALIAS\t\tCOMMAND"
    echo -e " -------------- ---------------------------------------------"
    for (( i = 0; i < ${#list[@]}; i++ )); do
        alias=`echo "${list[$i]}" | \
            awk -F"$PROJECT_DIR/main.sh run" '{print $1}' | \
            awk -F':' '{print $1}' | \
            awk -F"$BIN_DIR/" '{print $2}'`

        command=`echo "${list[$i]}" | awk -F"$PROJECT_DIR/main.sh run" '{print $2}'`

        echo -e " $(title $alias)\t\t$command"
    done
    echo -e ""
}