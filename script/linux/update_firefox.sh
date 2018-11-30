#!/bin/bash
set -x
if [ -z "$1" ];then
    echo "usage: $0 version"
    exit 1
fi
v=$1
cd /opt/download_firefox_release || exit 2
set -e
if [ ! -f "firefox-${v}.tar.bz2" ];then
	wget "https://ftp.mozilla.org/pub/firefox/releases/${v}/linux-x86_64-EME-free/en-US/firefox-${v}.tar.bz2"     -O firefox-${v}.tar.bz2
fi
if [ ! -f "firefox-${v}.tar.bz2.asc" ];then
	wget "https://ftp.mozilla.org/pub/firefox/releases/${v}/linux-x86_64-EME-free/en-US/firefox-${v}.tar.bz2.asc"     -O firefox-${v}.tar.bz2.asc
fi
# Fingerprint :
# Primary key fingerprint: 14F2 6682 D091 6CDD 81E3  7B6D 61B7 B526 D98F 0353
#     Subkey fingerprint: DCEA C5D9 6135 B91C 4EA6  72AB BBBE BDBB 24C6 F355
echo "gpg --keyserver pgp.mit.edu --receive-keys 0x14F26682D0916CDD81E37B6D61B7B526D98F0353"
gpg --keyserver pgp.mit.edu --receive-keys 0x14F26682D0916CDD81E37B6D61B7B526D98F0353
gpg2  --verify firefox-${v}.tar.bz2.asc firefox-${v}.tar.bz2
mkdir -p /opt/firefox_release/
rm -rf -- /opt/firefox_release/* ||true
tar -C /opt/firefox_release/ -jxvf firefox-${v}.tar.bz2
ls -t -- firefox-*.tar.bz2* |awk 'NR > 10'|while read ar ; do rm -f -- "${ar}";done;
exit 0
