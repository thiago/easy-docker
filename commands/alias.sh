#!/usr/bin/env bash

install_force=0
function alias_help {
    echo -e "
$(title Usage$): $PROGRAM_NAME $CURRENT_CMD alias-name[:version] [image[:version]]

Create a alias and pull image to easy run with docker.
If you do not specify an image, then it will use a default image if available.

$(title Options):
 -f, --force                    Force pull if image exist locally
 -h, --help                     This help screen

Ex.: $PROGRAM_NAME $CURRENT_CMD python
Ex.: $PROGRAM_NAME $CURRENT_CMD python:2.7.9 google/python
"
}

function install_find_image_locally {
	echo $(docker images | grep -w "^$1" | grep -w "$2" | awk '{print $3}')
}

function install_pull_image {
	docker pull $@
}

function install_tag_image {
	docker tag $@
}

function main_alias {
    shift

	local alias_name=""
	local alias_version=""
	local alias_image=""
	local image_name=""
	local image_version=""
	local image=""

    # Find options on args
	for opt in $@; do
	    if [ "${opt}" == "-h" -o "${opt}" == "--help" ]; then
            alias_help
            exit
        elif [ "${opt}" == "-f" -o "${opt}" == "--force" ]; then
        	shift
        	install_force=1
	    fi
	done

	# If not command
	if [ -z "${1-}" ]; then
		alias_help
        exit
    else
    	local alias_name=$(get_image_name $1)
		local alias_version=$(get_image_version $1)
		local alias_image=$1
	fi

	if [ -z "${2-}" ]; then
		local image_name=$alias_name
		local image_version=$alias_version
		: "${image_version:=latest}"
		local image=`find_default_image $image_name $image_version`
	else
		local image_name=$(get_image_name $2)
		local image_version=$(get_image_version $2)
		: "${image_version:=latest}"
		local image="$image_name:$image_version"
	fi

	echo "- Installing: \"$image\" to \"$alias_image\" alias"
	local image_exist=`install_find_image_locally $image_name $image_version`
	if [[ -z "${image_exist-}" ]]; then
		install_pull_image $image
		echo "- Image installed"
	elif [[ -n "${install_force-}" ]]; then
		install_pull_image $image
		echo "- Image installed"
	else
		echo -e "- Image already installed. ${color_blue}Use \"-f\" flag to force install again${color_default}"
	fi
	echo "- Set alias \"$alias_image\""
	mkdir -p $BIN_DIR
	echo -e "#!/usr/bin/env bash

# META: $alias_image $image
$PROJECT_DIR/main.sh run_image $alias_image $image \$@
" > $BIN_DIR/$alias_image
	chmod +x $BIN_DIR/$alias_image
	echo "- Alias setted"
}