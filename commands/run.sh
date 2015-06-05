#!/usr/bin/env bash


function usage_run {

    echo -e "
$(title Usage):
 $PROGRAM_NAME $CURRENT_CMD [options] alias[:version] [alias command]

$(title Options):
 -h, --help                     Display this help and exit
 -f, --file FILE                Specify an alternate compose file
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
    local IFS=$'\n'
    local docker_env_opt=""
    local docker_args=()
    local docker_custom_args=()
    local docker_flag=""
    local docker_opt=""
    local docker_value=""

    while [[ $1 = -?* ]]; do
      case $1 in
        -d | -i | -P | -t) docker_custom_args+=("$1") ;;
        *) docker_custom_args+=("$1 $2"); shift ;;
      esac
      shift
    done

    if [ -z "${1}" ]; then
        usage_run
        exit 1
    fi

    local args_length=$(($#))
    local args_array=${@:2:args_length}
    local image_repository=$(get_image_repository $1)
    local image_name=$(get_image_name $1)
    local image_version=$(get_image_version $1)
    if [ "$(echo $2 | head -c 1)" == ":" ]; then
        local image_version=$(get_image_version $2)
        local args_array=${@:3:args_length}
    fi

    local image_version_strip=${image_version//./}
    image_version_strip=${image_version_strip//-/}
    image_repository=${image_repository:=_}
    local ENVS=(
        "$PROJECT_DIR/schema/_.sh"
        "$PROJECT_DIR/schema/base.sh"
        "$PROJECT_DIR/schema/${image_name}.sh"
        "$PROJECT_DIR/schema/${image_repository}/${image_name}.sh"
        "$PROJECT_DIR/schema/${image_repository}/${image_name}/${image_version}.sh"
    )

    for env in ${ENVS[@]}; do
        if [ -f "${env}" ]; then
            . $env
        fi
    done

    # parse default help of docker cli
    local docker_help=(`docker run --help | grep -e --`)
    for (( i = 0; i < ${#docker_help[@]}; i++ )); do
        # get flag like -v -c -P
        docker_flag=`echo "${docker_help[$i]}" | awk -F', ' '{print $1}' | awk -F'-' '{print $2}'`
        # get option like --volume --cpu-shares --publish-all
        docker_opt=`echo "${docker_help[$i]}" | awk -F'=' '{print $1}' | awk -F'--' '{print $2}'`
        # get default value like [] 0 false
        docker_value=`echo "${docker_help[$i]}" | awk -F'=' '{print $2}' | awk '{print $1}'`
        # replace - to _ like cpu-shares to cpu_shares
        docker_env_opt=${docker_opt//-/_}

        # if exist value in option
        if [ -n ${!docker_opt} ]; then
            # parse default values by type to apply different ways to parse and insert arguments
            # if is a array then add in loop
            if is_array ${docker_env_opt}; then
                for item in $(eval "echo \"\${"${docker_env_opt}"[*]}\""); do
                    docker_args+=( "--$docker_opt $item" )
                done
            # if is a boolean
            elif [[ ${docker_value} = "false" ]] || [[ ${docker_value} = "true" ]]; then
                # and current value is not equal a default value
                if [[ ${!docker_env_opt} != ${docker_value} ]]; then
                    # then add in args
                    docker_args+=( "--$docker_opt" )
                fi
            # if is a string
            elif [[ ${docker_value} == \"* ]]; then
                # and current value is not equal a default value
                if [[ "\"${!docker_env_opt}\"" != ${docker_value} ]]; then
                    # then add in args
                    docker_args+=( "--$docker_opt ${!docker_env_opt}" )
                fi
            # if is a number
            elif [[ "${docker_value}" != "${!docker_env_opt}" ]]; then
                docker_args+=( "--$docker_opt ${!docker_env_opt}" )
            fi
        fi
    done

    # if repository of image is not a default library (_)
    if [[ "${image_repository}" != "_" ]]; then
        # then increment with /
        image_repository="${image_repository}/"
    else
        # then clean variable
        image_repository=""
    fi

    # join command line options into default args
    docker_args+=( "${docker_custom_args[*]}" )

    local cmd=`echo docker run ${docker_args[*]} ${image_repository}${image_name}:${image_version} ${args_array[*]}`

    eval $cmd
}

function dockerSwarm(){
    local name=$1
    local token=$(docker run swarm create 2>&1 | tail -1)
    docker-machine create -d virtualbox --swarm --swarm-master --swarm-discovery token://$token $name
    docker-machine create -d virtualbox --swarm --swarm-discovery token://$token ${name}1
    docker-machine create -d virtualbox --swarm --swarm-discovery token://$token ${name}2
    docker-machine create -d virtualbox --swarm --swarm-discovery token://$token ${name}3

    echo $token
}

function runOptsToEnv(){
    local IFS=$'\n'
    local docker_help=(`docker run --help | grep -e --`)
    local docker_opts=()
    local docker_env_opt=""
    local docker_args=()
    local docker_flag=""
    local docker_opt=""
    local docker_value=""

    for (( i = 0; i < ${#docker_help[@]}; i++ )); do
        docker_flag=`echo "${docker_help[$i]}" | awk -F', ' '{print $1}' | awk -F'-' '{print $2}'`
        docker_opt=`echo "${docker_help[$i]}" | awk -F'=' '{print $1}' | awk -F'--' '{print $2}'`
        docker_value=`echo "${docker_help[$i]}" | awk -F'=' '{print $2}' | awk '{print $1}'`
        docker_env_opt=${docker_opt//-/_}
        docker_opts+=(${docker_env_opt}=${docker_value//[]/()})
    done

    echo "${docker_opts[*]}"
}

function is_array() {
  local variable_name=$1
  [[ "$(declare -p $variable_name)" =~ "declare -a" ]]
}