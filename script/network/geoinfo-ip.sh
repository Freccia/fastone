#!/bin/bash

#Get ip info

if [ $# -ge 1 ];then
	curl ipinfo.io/$1
else
	curl ipinfo.io
fi
