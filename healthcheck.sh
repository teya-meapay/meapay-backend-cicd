#!/bin/bash
set -e
if [[ $(wget -nv -t1 --spider http://localhost:8081/health) -eq 0 ]];
then
	exit 0
else
	echo `wget -qO- http://localhost:8081/health` >> /proc/1/fd/1 && exit 1
fi
