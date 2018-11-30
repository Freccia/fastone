#!/usr/bin/env bash

# Place yourself in a directory full of git directories, then execute.
# It will pull all those repositories.

export GREEN='\033[0;32m'
export ENDC='\033[0m'
find . -type d -depth 1 -exec bash -c 'echo -e "${GREEN}{}${ENDC}"' \; \
		-exec git --git-dir={}/.git --work-tree=$PWD/{} pull origin master \;
# find . -name test -exec bash -c 'echo -e "${RED}{}"' \;
# find . -mindepth 1 -maxdepth 1 -type d -print -exec git -C {} pull \;
# find . -name "*.txt" \( -exec echo {} \; -o -exec true \; \) -exec grep banana {} \;
