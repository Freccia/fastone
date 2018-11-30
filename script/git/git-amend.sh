#!/bin/bash

git filter-branch --env-filter \
	'if [ "$GIT_AUTHOR_EMAIL" != "Freccia@users.noreply.github.com" ]; then
		GIT_AUTHOR_EMAIL=Freccia@users.noreply.github.com;
		GIT_AUTHOR_NAME="Freccia";
		GIT_COMMITTER_EMAIL=$GIT_AUTHOR_EMAIL;
		GIT_COMMITTER_NAME="$GIT_AUTHOR_NAME"; fi' -- --all

