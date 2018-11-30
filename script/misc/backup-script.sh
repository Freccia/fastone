#!/bin/bash

# tomash RUSH backup script

set -e
set -x
DIR=/home/root/BACKUP/karbon
cd ${DIR}
DATE=$(date +'%Y%m%d')
bkp="rootfs_karbon_snapshot"
time nice -n 19 ionice -c 3 rsync -ac \
		--hard-links \
		--numeric-ids \
		--stats \
		--delete \
		--progress \
		--exclude "/proc/*" \
		--exclude "/dev/*" \
		--exclude "/sys/*" \
		--exclude "/data/*" \
		--exclude "/media/*" \
		--exclude "/lost+found/*" \
		--exclude "/mnt/*" \
		--exclude "/run/*" \
		--exclude "/tmp/*" \
		--exclude "/data/*" \
		--exclude "/swapfile" \
		--exclude "/home/libvirt/*" \
		--exclude "/home/sharing/*" \
		--exclude "/home/root/BACKUP/*" \
		--exclude "/home/srk/Music/*" \
		--exclude "/home/srk/Videos/*" \
		--exclude "/home/srk/Downloads/*" \
		--exclude "/home/persobrowser/Downloads/*" \
		--exclude "/home/srk/tmp/*" \
		--exclude "/var/lib/lxc/*" \
		--exclude "/var/cache/*" \
		/ ${DIR}/${bkp}/
arname="${bkp}_${DATE}.tar.gz.gpg"
nice -n 10 ionice -c 3 tar c ${bkp}/ \
		|nice -n 19 pigz -c \
		|nice -n 15 gpg2 --cipher-algo AES256 --compress-algo Uncompressed --encrypt -r 0xXXXXXXXXXXX \
		|tee >(sha1sum > /tmp/backup-karbon-sha1sum-current-archive) \
		|pv \
		|nice -n 16 ssh -o Compression=no  user@SERVER "cat - > /data/BACKUP_karbon/${arname}"
h=$(cat /tmp/backup-karbon-sha1sum-current-archive|awk '{print $1}')
echo "${h} ${arname}" |ssh -o Compression=no  user@SERVER "cat - > /data/BACKUP_karbon/${arname}.sha1sum"

exit 0



