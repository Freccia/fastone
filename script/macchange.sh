#!/usr/bin/env bash

if [ `id -u` -ne 0 ]; then
	echo You must be root
	exit 1
fi

ip a
ip link set $1 down
if [ $? -ne 0 ]; then
	exit 10
fi
macchanger -r wlx784476b6c48a
ip link set $1 up
service network-manager restart
ip a

