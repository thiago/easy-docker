#!/usr/bin/env bash

. $UTILS_DIR/colors.sh

# Helpers {{{

function out {
  ((quiet)) && return

  local message="$@"
  if ((piped)); then
    message=$(echo $message | sed '
      s/\\[0-9]\{3\}\[[0-9]\(;[0-9]\{2\}\)\?m//g;
      s/✖/Error:/g;
      s/✔/Success:/g;
    ')
  fi
  printf '%b\n' "$message";
}

function die { out "$@"; exit 1; } >&2
function err { out " \033[1;31m✖\033[0m  $@"; } >&2
function success { out " \033[1;32m✔\033[0m  $@"; }

# Verbose logging
function log { (($verbose)) && out "$@"; }

# Notify on function success
function notify { [[ $? == 0 ]] && success "$@" || err "$@"; }

# Escape a string
function escape { echo $@ | sed 's/\//\\\//g'; }

# Unless force is used, confirm with user
function confirm {
  (($force)) && return 0;

  read -p "$1 [y/N] " -n 1;
  [[ $REPLY =~ ^[Yy]$ ]];
}

function parse_yaml {
   local prefix=$2
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
   sed -ne "s|^\($s\)\($w\)$s:$s\"\(.*\)\"$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
   awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
      }
   }'
}

function not_found {
    ([ -n $1 ]) && return
    case $1 in
        -*)
            err "Option \"$1\" not found"
            ;;
        *)
            err "Command \"$1\" not found"
            ;;
    esac
    echo ""
}

function get_image_name {
    local list=(${1//:/ })
    if [ "$(echo $1 | head -c 1)" == ":" ]; then
        return
    else
        echo "${list[0]-}"
    fi
}

function get_image_version {
    local list=(${1//:/ })
    if [ "$(echo $1 | head -c 1)" == ":" ]; then
        echo "${list[0]:=latest}"
    else
        echo "${list[1]:=latest}"
    fi
}

function find_default_image {
    echo $(. $UTILS_DIR/images.sh $@)
}