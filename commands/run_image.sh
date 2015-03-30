#!/usr/bin/env bash

function main_run_image {
    shift
    local name=$(get_image_name $1)
    if [ "$(echo $2 | head -c 1)" == ":" ]; then
        local version=$(get_image_version $2)
    else
        local version=$(get_image_version $1)
    fi
    version=${version//./""}
    version=${version//-/""}
    local args_length=$(($#))
    local args_array=${@:2:args_length}

    TMPL_FILE="$PROJECT_DIR/installed/$name.yml"
    TMPL_ENV="$PROJECT_DIR/installed/$name.env"
    TMPL_ENV_COMMON="$PROJECT_DIR/installed/common.env"
    TMPL_TMP="TMPL_CURRENT=\"`echo -e "$(cat $TMPL_FILE)"`\""

    if [ -f "${TMPL_ENV_COMMON}" ]; then
        eval $(cat $TMPL_ENV_COMMON)
    fi

    if [ -f "${TMPL_ENV}" ]; then
        eval $(cat $TMPL_ENV)
    fi

    eval "$TMPL_TMP"
    echo -e "$TMPL_CURRENT" > $TMP_DIR/$name.yml

    docker-compose -f $TMP_DIR/$name.yml -p $(pwd) run --rm $name$version $args_array
}