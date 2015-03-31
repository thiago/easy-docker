#!/usr/bin/env bash

url=https://github.com/trsouz/easy-docker/archive/master.tar.gz

has() {
  type "$1" > /dev/null 2>&1
}

if has "curl"; then
    curl -L $url | tar xz
elif has "wget"; then
    wget --no-check-certificate $url -O - | tar xz
else
    echo "You need curl or wget installed to continue"
    exit 1
fi
mkdir -p $HOME/.easydocker
cp -rp easy-docker-master/* $HOME/.easydocker/
rm -rf easy-docker-master
. $HOME/.easydocker/install.sh

