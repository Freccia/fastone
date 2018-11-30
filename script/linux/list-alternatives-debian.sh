#!/bin/bash

for i in /etc/alternatives/*; do 
  LANG=C update-alternatives --display "${i#/etc/alternatives/}"
done 2>/dev/null | awk '/manual.mode/{print $1}'


