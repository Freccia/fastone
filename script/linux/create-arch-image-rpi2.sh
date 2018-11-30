#!/bin/sh -ex
losetup /dev/loop0 && exit 1 || true
image=arch-linux-$(date +%Y%m%d).img
wget -N http://archlinuxarm.org/os/ArchLinuxARM-rpi-2-latest.tar.gz
truncate -s 1G $image
losetup /dev/loop0 $image
parted -s /dev/loop0 mklabel msdos
# parted -s /dev/loop0 unit MiB mkpart primary fat32 -- 0 32
parted -s /dev/loop0 unit MiB mkpart primary fat32 -- 1 32
parted -s /dev/loop0 set 1 boot on
parted -s /dev/loop0 unit MiB mkpart primary ext2 -- 32 -1
parted -s /dev/loop0 print
mkfs.vfat -I -F 32 -n System /dev/loop0p1
mkfs.ext4 -L root -b 4096 -E stride=4,stripe_width=1024 /dev/loop0p2
mkdir -p arch-boot
mount /dev/loop0p1 arch-boot
mkdir -p arch-root
mount /dev/loop0p2 arch-root
tar xfz ArchLinuxARM-rpi-2-latest.tar.gz -C arch-root
sed -i "s/ defaults / defaults,noatime /" arch-root/etc/fstab
mv arch-root/boot/* arch-boot/
umount arch-boot arch-root
losetup -d /dev/loop0
