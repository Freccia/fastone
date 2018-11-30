#!/bin/bash

#
# Created by freccia
# july 2017
#

# Make sure you are root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root." 1>&2
   exit 1
fi

ARCH="`uname`"

echo "Arch: $ARCH"

if [[ $ARCH -ne "Darwin" ]] && [[ $ARCH -ne "Linux" ]]; then
	echo "Os is neither Darwin nor Linux. Abort."
fi

# Test if you inputted the device name
if [[ $# < 1 ]]; then
	printf "Wrong number of arguments.\n"
	printf "Usage: ./macSpoof.sh [device-name]\n"
	exit 1
fi

CUR_MAC=`ifconfig | grep -C 3 $1 | grep ether |
		sed "s/^.* \(\([0-9a-z]\{2\}:\)\{5\}[0-9a-z]\{2\}\).*$/\1/"`

# Or maybe this is better (only Linux):
#CUR_MAC=`cat /sys/class/net/$1/address`

if [[ -z $CUR_MAC ]];then
	printf "Could not find this device.\n"
	exit 1
fi

printf "Current MAC: $CUR_MAC\n"

NEW_MAC=`openssl rand -hex 6 | sed 's/\(..\)/\1:/g;s/.$//'`

# Test if new mac first byte is even
TEST=`echo $NEW_MAC | sed 's/\(..\).*$/\1/g'`

if [ $(($((16#$TEST))%2)) -eq 1 ]; then
	NEW_MAC="`echo $NEW_MAC | sed 's/^..\(\(:[0-9a-f]\{2\}\)\{5\}\)/02\1/'`"
fi

echo "New MAC: $NEW_MAC"

if [ $ARCH == "Darwin" ]; then
		sudo ifconfig $1 down
elif [ $ARCH == "Linux" ]; then
		# sudo ifconfig $1 down
		sudo ip link set $1 down
fi

if [[ $? != 0 ]];then
	printf "Failed putting down $1. Abort.\n"
	exit 1
fi

if [ $ARCH == "Darwin" ]; then
		echo "Here!"
		sudo ifconfig $1 lladdr $NEW_MAC
elif [ $ARCH == "Linux" ]; then
		# sudo ifconfig $1 hw ether $NEW_MAC
		# sudo ip link set $1 address $NEW_MAC
		echo "Changing mac: $NEW_MAC"
fi

if [[ $? != 0 ]];then
	printf "An error occurred changing MAC on $1. Abort.\n"
	exit 1
fi

if [ $ARCH == "Darwin" ]; then
		sudo ifconfig $1 up
elif [ $ARCH == "Linux" ]; then
		# sudo ifconfig $1 up
		sudo systemctl restart NetworkManager
		sleep 2
		sudo ip link set $1 up
fi

if [[ $? != 0 ]];then
	printf "Failed getting up $1. Abort.\n"
	exit 1
fi
