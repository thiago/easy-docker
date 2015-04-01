#!/usr/bin/env bash

clean_all=""
clean_force=""
clean_object=""
clean_method=""

function clean_docker {
	docker $clean_method $clean_force $@
}

function clean_images {
	if [ -n "${clean_all}" ]; then
	    if confirm "This command will remove all images of the docker. Are you sure?"; then
            list=$(docker images -aq)
        fi
	else
		list=$(docker images | grep "^<none>" | awk '{print $3}')	
	fi

	if [ -n "${list}" ]; then
	    notify "Removing images"
		clean_docker $list
	fi
}

function clean_ps {
    list=$(docker ps -aq)
	if [ -n "${list}" ]; then
		clean_docker $list
	fi
}

function clean_help {
    echo -e "
$(title Usage): $PROGRAM_NAME $CURRENT_CMD command [options]

$(title Commands):
 i, images                      Clean images. The default only remove untagged images (with <none>)
 p, s, ps, c, containers        Clean containers. The default only remove stop containers

$(title Options):
 -a, --all                      Clean all. The default remove only stop containers
                                and untagged images (with <none>)

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