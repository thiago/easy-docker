#!/usr/bin/env bash

function main_run_image {
    shift
    local name=$1
    local image=$2
    shift; shift
    if [ "${1-}" == "d" ]; then
        shift
        docker run --rm -ti -v $(pwd):$(pwd) -w $(pwd) $image /bin/sh $@
    else
        docker run --rm -ti -v $(pwd):$(pwd) -w $(pwd) $image $(get_image_name $name) $@
    fi
}