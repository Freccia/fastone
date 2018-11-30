#!/bin/bash

repos="`find . -maxdepth 1 -type d`"

for repo in $repos;
do
	if [ "$repo" != "." ];then
		echo "Repo: $repo"
		cd $repo
		$@
		cd ..
	fi
done
