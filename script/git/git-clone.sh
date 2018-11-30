#!/bin/bash

repos="$(grep '<a href="/' repositories repositories-2 | sed 's/^.*<a href="\///g' | sed 's/" itemprop.*$//g')"

for repo in $repos;
do
	if ! [ -f `basename ${repo}` ];then
		git clone git@github.com:${repo}.git
	fi
done
