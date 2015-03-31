#!/usr/bin/env bash

# Preamble {{{

# Exit immediately on error
set -e

# Detect whether output is piped or not.
[[ -t 1 ]] && piped=0 || piped=1

# Defaults
force=0
quiet=0
verbose=0
interactive=0
args=()

# Find current path 
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done

if [ -n "${EASY_DOCKER_ALIAS}" ]; then
    PROGRAM_NAME=$EASY_DOCKER_ALIAS
else
    PROGRAM_NAME=$(basename $0)
fi

# Folders
PROJECT_DIR=`echo "$( cd -P "$( dirname "$SOURCE" )" && pwd )"`
CMDS_DIR=$PROJECT_DIR/commands
UTILS_DIR=$PROJECT_DIR/utils
TMP_DIR=$PROJECT_DIR/tmp
BIN_DIR=$PROJECT_DIR/bin
PERSISTENT_DIR=$PROJECT_DIR/persistent

mkdir -p $TMP_DIR $BIN_DIR
version="v0.1"

# Include utils helpers
. $UTILS_DIR/utils.sh

# A list of all variables to prompt in interactive mode. These variables HAVE
# to be named exactly as the longname option definition in usage().
interactive_opts=()

# Print usage
usage() {

    echo -e "Easy Docker is a simple command line tools to use the docker on a day-by-day

$(title Usage):
 $PROGRAM_NAME [options] command [command options]

$(title Options):
 -f, --force                    Skip user interaction
 -h, --help                     Display this help and exit
 -q, --quiet                    Quiet (no output)
 -v, --verbose                  Print debug messages
 -V, --version                  Output version information and exit

$(title Commands):
 ls                             Show all installed alias
 clean                          Cleanup images or containers
 alias                          Pull a image and create alias
"
}

# Set a trap for cleaning up in case of errors or when script exits.
rollback() {
  die
}

# Put your script here
main() {
  if [ -f $CMDS_DIR/${args[0]}.sh ]; then
    . $CMDS_DIR/${args[0]}.sh
    CURRENT_CMD=${args[0]}
    main_${CURRENT_CMD} ${args[@]}
  else
    not_found ${args[0]}
    exit 1
  fi
}

# }}}
# Boilerplate {{{

# Prompt the user to interactively enter desired variable values. 
prompt_options() {
  local desc=
  local val=
  for val in ${interactive_opts[@]}; do
    # Skip values which already are defined
    [[ $(eval echo "\$$val") ]] && continue
    # Parse the usage description for spefic option longname.
    desc=$(usage | awk -v val=$val '
      BEGIN {
        # Separate rows at option definitions and begin line right before
        # longname.
        RS="\n +-([a-zA-Z0-9], )|-";
        ORS=" ";
      }
      NR > 3 {
        # Check if the option longname equals the value requested and passed
        # into awk.
        if ($1 == val) {
          # Print all remaining fields, ie. the description.
          for (i=2; i <= NF; i++) print $i
        }
      }
    ')
    [[ ! "$desc" ]] && continue

    echo -n "$desc: "

    # In case this is a password field, hide the user input
    if [[ $val == "password" ]]; then
      echo "PASS"
      stty -echo; read password; stty echo
      echo
    # Otherwise just read the input
    else
      eval "read $val"
    fi
  done
}

# Iterate over options breaking -ab into -a -b when needed and --foo=bar into
# --foo bar
optstring=h
unset options
while (($#)); do
  case $1 in
    # If option is of type -ab
    -[!-]?*)
      # Loop over each character starting with the second
      for ((i=1; i < ${#1}; i++)); do
        c=${1:i:1}

        # Add current char to options
        options+=("-$c")

        # If option takes a required argument, and it's not the last char make
        # the rest of the string its argument
        if [[ $optstring = *"$c:"* && ${1:i+1} ]]; then
          options+=("${1:i+1}")
          break
        fi
      done
      ;;
    # If option is of type --foo=bar
    --?*=*) options+=("${1%%=*}" "${1#*=}") ;;
    # add --endopts for --
    --) options+=(--endopts) ;;
    # Otherwise, nothing special
    *) options+=("$1") ;;
  esac
  shift
done
set -- "${options[@]}"
unset options

# Set our rollback function for unexpected exits.
trap rollback INT TERM EXIT

# A non-destructive exit for when the script exits naturally.
safe_exit() {
  trap - INT TERM EXIT
  exit
}

# }}}
# Main loop {{{

# Print help if no arguments were passed.
[[ $# -eq 0 ]] && set -- "--help"

# Read the options and set stuff
while [[ $1 = -?* ]]; do
  case $1 in
    -f|--force) force=1 ;;
    -h|--help) usage >&2; safe_exit ;;
    -q|--quiet) quiet=1 ;;
    -v|--verbose) set -x; verbose=1 ;;
    -V|--version) out "$PROGRAM_NAME $version"; safe_exit ;;
    --endopts) shift; break ;;
    *) not_found $1; exit 1;;
  esac
  shift
done

# Store the remaining part as arguments.
args+=("$@")

if ((interactive)); then
  prompt_options
fi

# You should delegate your logic from the `main` function
main

# This has to be run last not to rollback changes we've made.
safe_exit