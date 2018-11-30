#!/bin/bash
if [ -z "$1" ];then
    echo "usage example: $0 /dev/sda"
    exit 1
fi
dev="$1"
if [ ! -b "$dev" ];then
    echo "invalide block device $dev"
    exit 1
fi

#set -x
device=$(basename ${dev})
bsm=32
count=1
#sample=50
sample=100
partsize=$(cat /proc/partitions  |awk '{print $4,$3}'|egrep "^${device} [0-9]+"|awk '{print $2}')
pm=$(echo "${partsize} / 1024" |bc )
sk=$(echo "$pm / ${bsm} / $sample" |bc)

echo "Device:     ${device}"
echo "Part-size:  ${partsize} bytes"
echo "PM:         ${pm}"
echo "BS:         ${bsm}M"
echo "Skip:       ${sk}"

echo 3 > /proc/sys/vm/drop_caches
dd --help > /dev/null 2>&1
sleep 2
skip=0
set +x

for i in $(seq 0 $sample)
do

    echo -n "Zone ${i} $(echo ${skip} |bc)-$(echo ${skip}+${bsm} |bc) "

    dd if=${dev} of=/dev/null iflag=nocache bs=${bsm}M count=${count} skip=${skip} 2>&1 |tail -n 1 |awk -F, '{print $3}'

    sleep 0.05
    skip=$(( skip + sk ))
done
