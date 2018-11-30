#!/usr/bin/env bash

# This script lines are useful to find 
# files by permissions

DIR="$1"

# ust modify the searched permissions
ls -aRl "$DIR" | awk '$1 ~ /^.[rwx-]{3}[rwx-]{3}r-x/' 2>/dev/null

exit 0
# Other options
ls -aRl /etc/ | awk '$1 ~ /^.*w.*/' 2>/dev/null     # Anyone
ls -aRl /etc/ | awk '$1 ~ /^..w/' 2>/dev/null       # Owner
ls -aRl /etc/ | awk '$1 ~ /^.....w/' 2>/dev/null    # Group
ls -aRl /etc/ | awk '$1 ~ /w.$/' 2>/dev/null        # Other

find /etc/ -readable -type f 2>/dev/null               # Anyone
find /etc/ -readable -type f -maxdepth 1 2>/dev/null   # Anyone

