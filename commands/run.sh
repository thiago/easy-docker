#!/usr/bin/env bash


function usage_run {

    echo -e "
$(title Usage):
 $PROGRAM_NAME $CURRENT_CMD [options] alias[:version] [alias command]

$(title Options):
 -h, --help                     Display this help and exit
 -i, --interactive=false        Enter in container with shell
 -e KEY=VALUE                   Set an environment variable (can be used multiple times)
 --entrypoint=/bin/bash         Change the entrypoint

$(title Example):
 $PROGRAM_NAME $CURRENT_CMD python -V
 $PROGRAM_NAME $CURRENT_CMD python:2.7 -m SimpleHTTPServer 80
 $PROGRAM_NAME $CURRENT_CMD -i python
 $PROGRAM_NAME $CURRENT_CMD --entrypoint /bin/bash python ls
"
}

function upsearch {
  slashes=${PWD//[^\/]/}
  directory="$PWD"
  for (( n=${#slashes}; n>0; --n ))
  do
    test -e "$directory/$1" && echo "$directory/$1" && return
    directory="$directory/.."
  done
}

function main_run {
    shift
    local interactive=""
    local custom_entrypoint=""
    local envs=()
    while [[ $1 = -?* ]]; do
      case $1 in
        -h|--help) usage_run >&2; safe_exit;;
        -i|--interactive) interactive=1;;
        -f|--file) shift; file=$1;;
        -e) shift; envs+=("-e $1") ;;
        --entrypoint) shift; custom_entrypoint=$1 ;;
        *) not_found $1; exit 1;;
      esac
      shift
    done

    if [ -z "${1}" ]; then
        usage_run
        exit 1
    fi
    local args_length=$(($#))
    local args_array=${@:2:args_length}
    local name=$(get_image_name $1)
    local version=$(get_image_version $1)
    if [ "$(echo $2 | head -c 1)" == ":" ]; then
        local version=$(get_image_version $2)
        local args_array=${@:3:args_length}
    fi
    version_strip=${version//./""}
    version_strip=${version_strip//-/""}

    TMPL_FILE="${file:=$PROJECT_DIR/schema/base.yml}"
    TMPL_ENV_COMMON="$PROJECT_DIR/schema/base.env"
    TMPL_ENV_PLATFORM="$PROJECT_DIR/schema/$name.env"

    if [ -f "${TMPL_ENV_COMMON}" ]; then
        eval $(cat $TMPL_ENV_COMMON)
    fi

    if [ "${interactive}" == 1 ] || [ "${custom_entrypoint}" != "" ]; then
        custom_entry="${name}_entrypoint=\"${custom_entrypoint:=${entrypoint:="/bin/bash -c"}}\""
        eval "$custom_entry"
    fi

    if [ -f "${TMPL_ENV_PLATFORM}" ]; then
        eval $(cat $TMPL_ENV_PLATFORM)
    fi

    if [ "${#args_array}" != 0 ]; then
        if [ "$entrypoint" == "/bin/bash" ] || [ "$entrypoint" == "/bin/sh" ]; then
            echo -e "#!$entrypoint \n${args_array[@]}" > $TMP_DIR/entrypoint.sh
            chmod +x $TMP_DIR/entrypoint.sh
            entrypoint=$TMP_DIR/entrypoint.sh
            volumes+=("$TMP_DIR/entrypoint.sh:$TMP_DIR/entrypoint.sh")
            args_array=""
        fi
    fi


    if [ -f "${TMPL_FILE}" ]; then
        TMPL_TMP="TMPL_CURRENT=\"`echo -e "$(cat $TMPL_FILE)"`\""
        eval "$TMPL_TMP"
        echo -e "$TMPL_CURRENT" > $TMP_DIR/${name}_with_tab.yml
        expand -t 2 $TMP_DIR/${name}_with_tab.yml > $TMP_DIR/$name.yml
    else
        err "File \"${TMPL_FILE}\" not found"
        exit 1
    fi

    docker-compose -f $TMP_DIR/$name.yml run $envs --service-ports --rm $name$version_strip ${args_array[@]}
}