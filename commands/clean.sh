#!/usr/bin/env bash

clean_all=""
clean_force=""
clean_object=""
clean_method=""

function clean_docker {
    docker $clean_method $clean_force $@
}

function clean_images {
    local msg=""
    if [ -n "${clean_all}" ]; then
        msg="Removing all images"
        list=$(docker images -aq)
    else
        msg="Removing images with filter \"dangling=true\""
        list=$(docker images -q -f "dangling=true")
    fi

    if [ -n "${list}" ]; then
        success $msg
        out $(clean_docker $list)
    else
        success "No images to be removed"
    fi
}

function clean_ps {
    local msg=""
    if [ -n "${clean_all}" ]; then
        msg="Removing all containers"
        list=$(docker ps -aq)
    else
        msg="Removing containers with filter \"status=exited\""
        list=$(docker ps -q -f "status=exited")
    fi

    if [ -n "${list}" ]; then
        success $msg
        out $(clean_docker $list)
    else
        success "No containers to be removed"
    fi
}

function clean_help {
    echo -e "
$(title Usage): $PROGRAM_NAME $CURRENT_CMD [options] command

$(title Commands):
 i, images                      Clean images. The default only remove images \"dangling\" (with <none>)
 p, s, ps, c, containers        Clean containers. The default only remove containers \"exited\"

$(title Options):
 -a, --all                      Clean all.
 -f, --force                    Force remove
 -h, --help                     This help screen
"
}

function main_clean {
    shift;
    while [ "${1-}" != "" ]; do
        case $1 in
            "-h" | "--help")
                clean_help
                exit
                ;;
            "-a" | "--all")
                clean_all="-a"
                ;;
            "-f" | "--force")
                clean_force="-f"
                ;;
            "i" | "images")
                clean_object="images"
                clean_method="rmi"
                ;;
            "p" | "s" | "ps" | "c" | "containers")
                clean_object="ps"
                clean_method="rm"
                ;;
            *)
                not_found $1
                clean_help
                exit
                ;;
        esac
        shift
    done
    if [ "${clean_object}" == "images" ]; then
        clean_images
    elif [ "${clean_object}" == "ps" ]; then 
        clean_ps
    else
        clean_help
    fi
}