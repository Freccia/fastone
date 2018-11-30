#!/usr/bin/env bash

if [ -n $1 ] ; then
  nc -v -l 80 < $1
else
      echo "Usage: ./share-file-nc.sh /path/to/file"
fi

