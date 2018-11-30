#!/usr/bin/env bash

RED='\033[1;31m'
BLUE='\033[1;34m'
YELLOW='\033[1;33m'
ENDC='\033[0m'

echo -e $RED "This is such a powerfull tool, please be careful using it." $ENDC
read a
echo -e $BLUE "As with great powers comes great responsibilities..." $ENDC
read a

if [ $# -lt 1 ] || [ `dirname $1` != "/dev" ] ;then
    echo -e $BLUE "Usage: wipe-iT [disk-device]" $ENDC
fi

sleep 1

echo -e $YELLOW "Wait a sec."
echo -e " Are you really, REALLY sure you wanna wipe $1 device ? (y/n)" $ENDC
read R

if [[ ( -n $R ) && ( "$R" == "y" || "$R" == "yes" ) ]] ;then
    echo -e $BLUE "As you want I am deleting the device $1" $ENDC

    for n in `seq 7`;
    do
        exit 1
    #   dd if=/dev/urandom of=$1 bs=8b conv=notrunc
    done

else
    echo -e $RED ABORTING $ENDC
fi
