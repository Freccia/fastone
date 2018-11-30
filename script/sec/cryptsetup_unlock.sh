#!/bin/bash
set -x
sed -i 's/issue_discards = 0/issue_discards = 1/g' /etc/lvm/lvm.conf
set -e
cryptsetup --allow-discards luksOpen /dev/md2 data-ssd
set +e
ls /dev/ |grep md127 > /dev/null
if [ $? -eq 0 ];then
	set -e
	cryptsetup luksOpen /dev/md127 data-hdd
else
	set -e
	cryptsetup luksOpen /dev/md9 data-hdd
fi

pvscan
vgscan
lvscan
vgchange -ay
lvscan
sleep 1
mount -o discard,relatime /dev/mapper/luksssd-luks--data--ssd /data-ssd
mount -o relatime /dev/mapper/lukshdd-backup--sftp--groupetec /data/backup--sftp--groupetec/
#
set +e
systemctl restart lxc
systemctl restart libvirtd.service
systemctl restart libvirt-guests.service

# start some vm etc
#virsh start SQLserver2012-MODB-RD-v1


