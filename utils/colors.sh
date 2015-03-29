#!/usr/bin/env bash


color_default='\033[0m'
color_black='\033[30m'
color_red='\033[31m'
color_green='\033[32m'
color_yellow='\033[33m'
color_blue='\033[34m'
color_magenta='\033[35m'
color_cyan='\033[36m'
color_white='\033[37m'


color_gray='\033[1;30m'

function msg {
    color=${1}
    shift
    echo -en "${color}$@$color_default"
}

function default {
    msg $color_default $@
}

function black {
    msg $color_black $@
}

function gray {
    msg $color_gray $@
}

function red {
    msg $color_red $@
}

function green {
    msg $color_green $@
}

function yellow {
    msg $color_yellow $@
}

function blue {
    msg $color_blue $@
}

function magenta {
    msg $color_magenta $@
}

function cyan {
    msg $color_cyan $@
}

function white {
    msg $color_white $@
}

function title {
    blue $@
}