#!/usr/bin/env bash

# Custom variables
current_path="${current_path:=$(pwd)}"
persistent_path="${persistent_path:=$PERSISTENT_DIR}/$image_repository/$image_name/$image_version"
persistent_path_container="${persistent_path_container:=/persistent}"
port_host="${port_host:=}"
port_container="${port_container:=80}"

# Docker variables
#rm=true
#tty=true
#interactive=true
workdir="${workdir:=$current_path}"
env=(
    "PATH=${persistent_path_container}/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
    "VIRTUAL_HOST=${image_name}.$(basename `pwd`).docker.dev,${image_version}.${image_name}.${image_repository}.docker.dev,${image_name}.${image_repository}.docker.dev,${image_repository}.docker.dev"
)
publish=(
    "$port_host:$port_container"
)
volume=(
    "$current_path:$current_path"
    "$persistent_path:$persistent_path_container"
)
