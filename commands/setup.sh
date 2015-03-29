#!/usr/bin/env bash


function main_setup {
	echo "export PATH=$BIN_DIR:\$PATH" >> $HOME/.bash_profile
	source $HOME/.bash_profile 2> /dev/null
}