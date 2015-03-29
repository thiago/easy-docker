#!/usr/bin/env bash

function main_ls {
	grep -nr META* $BIN_DIR | awk '{print $3, $4}'
}