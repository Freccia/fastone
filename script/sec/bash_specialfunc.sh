#!/bin/bash
function makepassphrase_old () {
 echo "Enter you passphrase, (display is disable),mode echo -n, default hash is whirlpool"
 read -s TMPPASS
 echo -n "${TMPPASS}"|openssl whirlpool
 TMPPASS=""
 unset TMPPASS
}
function makepassphrase () {
 echo "Enter you passphrase, (display is disable) mode = echo -n 'yourpass' |openssl whirlpool -binary |base64 -w 0"
 read -s TMPPASS
 echo -n "${TMPPASS}" |openssl whirlpool -binary |base64 -w 0
 TMPPASS=""
 unset TMPPASS
 echo ""
}
