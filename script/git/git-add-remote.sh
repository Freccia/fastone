#!/bin/bash

repos="`find . -maxdepth 1 -type d`"
name="scw"
url="ssh://git@212.47.241.193:666/~/fxrc/"
branch="master"

for repo in $repos;
do
	if [ "$repo" != "." ];then
		echo name=$name url=${url}$( basename ${repo})  pwd=`pwd`
		cd $repo
		#git remote add $name ${url}$( basename ${repo})
		git remote set-url $name --push --add ${url}$( basename ${repo})
		#git push $name $branch
		git push
		cd ..
	fi
done
