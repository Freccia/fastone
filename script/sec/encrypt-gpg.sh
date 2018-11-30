#!/bin/bash

#######
# GPG - non interactive mode
#
# gpg --yes --batch --passphrase=[Enter your passphrase here] -c filename.txt
# gpg --yes --batch --passphrase=[Enter your passphrase here] filename.txt.gpg
###

if [[ $# < 2 ]]; then
	echo "Usage: ./encrypt-gpg.sh dirname outfile [ passphrase ]"
	echo "note:  give 'outfile' without extension"
	echo "ex:    ./encrypt-gpg.sh mydir otarfile"
	exit 1
fi

DIR="$1"
TAR_FILE="$2.tar.gz"

if [ -n "$3" ]; then
	PASSPHRASE="$3"
fi

echo "Dir: $DIR"
echo "Tar: $TAR_FILE"
echo "Pwd: $PASSPHRASE"

if ! [ -d "$DIR" ]; then
	echo "The filename provided is not a directory. Abort."
	exit 1
fi

if [[ `tar -pczf "$TAR_FILE" "$DIR"` -ne 0 ]];then
	echo "Tar error. Abort."
	exit 1
fi

if [ -n "$PASSPHRASE" ]; then
	echo "gpg --yes --batch --passphrase='$PASSPHRASE' -c '$TAR_FILE'"
	gpg --yes --batch --passphrase="$PASSPHRASE" -c "$TAR_FILE"
else
	echo "gpg --yes -c '$TAR_FILE'"
	gpg --yes -c "$TAR_FILE"
fi

if [[ $? -ne 0 ]]; then
	echo "Gpg failed. Abort."
	exit 1
fi

if [ -f "$DIR" ] || [ -d "$DIR" ]; then
	rm -r "$DIR"
fi
if [ -f "$TAR_FILE"  ]; then
	rm "$TAR_FILE"
fi

