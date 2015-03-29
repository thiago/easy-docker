#!/bin/bash

if [ -n "${1-}" ]; then
	if [ -z "${2-}" ]; then
		tag=latest
	else
		tag=$2
	fi
	case $1 in
		python*)
			echo $1:$tag
		    ;;
		ash | busybox | cat | catv | chattr | chgrp | chmod | chown | cp | cpio | date | dd | df | dmesg | dnsdomainname | dumpkmap | echo | egrep | false | fdflush | fgrep | getopt | grep | gunzip | gzip | hostname | kill | linux32 | linux64 | ln | login | ls | lsattr | mkdir | mknod | mktemp | more | mount | mountpoint | mt | mv | netstat | nice | pidof | ping | pipe_progress | printenv | ps | pwd | rm | rmdir | run-parts | sed | setarch | setserial | sh | sleep | stty | su | sync | tar | touch | true | umount | uname | usleep | vi | watch | zcat)
			echo busybox
		    ;;
	esac
fi