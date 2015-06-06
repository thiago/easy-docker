#!/usr/bin/env bash


function usage_alias {

    echo -e "
$(title Usage):
 $PROGRAM_NAME $CURRENT_CMD ALIAS [RUN OPTIONS] [IMAGE][:VERSION] [ARGS...]

$(title Options):
 -h, --help                     Display this help and exit

$(title Example):
 $PROGRAM_NAME $CURRENT_CMD server -ti python:2 -m SimpleHTTPServer 80
 $PROGRAM_NAME $CURRENT_CMD python -i python:latest
"
}

function main_alias {
    shift
    local is_local=0
    while [[ $1 = -?* ]]; do
      case $1 in
        -h|--help) usage_alias >&2; safe_exit;;
        -l|--local) is_local=1;;
        *) not_found $1; exit 1;;
      esac
      shift
    done

    if [ -z "${1}" ]; then
        usage_alias
        exit 1
    fi

    local alias_name=$1
    shift
    mkdir -p $BIN_DIR
	echo -e "#!/usr/bin/env bash

$PROJECT_DIR/main.sh run $@ \$@
" > $BIN_DIR/$alias_name
	chmod +x $BIN_DIR/$alias_name
}