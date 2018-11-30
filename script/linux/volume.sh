#!/bin/bash

if [ $# > 1 ];then
	pactl -- set-sink-volume 0 $1%
else
	echo "Usage: ./volume.sh [ volume% ]"
fi
