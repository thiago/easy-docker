#!/usr/bin/env bash

set -e

force=0
for arg in $@; do
  case $arg in
    -f) force=1;;
  esac
done

case $OSTYPE in
  darwin*)
    CONFIG_FILE=.bash_profile
    ;;
  *)
    CONFIG_FILE=.bashrc
    ;;
esac

SOURCE="${BASH_SOURCE[0]}"; while [ -h "$SOURCE" ]; do  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"; SOURCE="$(readlink "$SOURCE")";  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" ; done
EASY_DOCKER=`echo "$( cd -P "$( dirname "$SOURCE" )" && pwd )"`
CONFIG=$HOME/$CONFIG_FILE
EASY_DOCKER_ALIAS=d

if [ ! -f $CONFIG ]; then
    echo '#!/usr/bin/env bash' > $CONFIG
fi

if [ $force = 0 ]; then
    read -p "Enter the alias you would like to use (default is \"$EASY_DOCKER_ALIAS\"):" EASY_DOCKER_ALIAS
    EASY_DOCKER_ALIAS=${EASY_DOCKER_ALIAS:-d}
fi

SETTINGS="export EASY_DOCKER_DIR=$EASY_DOCKER; \
export EASY_DOCKER_ALIAS=$EASY_DOCKER_ALIAS; \
export EASY_DOCKER=\$EASY_DOCKER_DIR/main.sh; \
alias $EASY_DOCKER_ALIAS=\$EASY_DOCKER; \
export PATH=\$EASY_DOCKER_DIR/bin:\$PATH"

if [ `cat $CONFIG | grep 'EASY_DOCKER_DIR' | wc -l` = 0 ]; then
    echo -e "
# Easy Docker Settings
$SETTINGS

" >> $CONFIG
else
    sed -i.old "s|EASY_DOCKER_DIR=.*$|${SETTINGS}|g" $CONFIG
fi

echo "EasyDocker was successfully installed. Type \"$EASY_DOCKER_ALIAS\" to see the help.
To apply the settings type \"source ~/$CONFIG_FILE\" or close and open your terminal."

set +e
. $CONFIG