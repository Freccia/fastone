#!/usr/bin/env bash

#  Alternatives
#    http://www.ifconfig.me
#    http://www.icanhazip.com
#    http://ipecho.net/plain
#    http://ipogre.com
#    http://indent.me
#    http://bot.whatismyipaddress.com
#    https://check.torproject.org
#    wget http://ipecho.net/plain -O - -q ; echo
#

# Reliable method
#dig +short myip.opendns.com @resolver1.opendns.com

if [ $# -gt 0 ];then
		if [ $1 == "-full" ];then
				curl http://ipleak.com/full-report > ipleak.html
		else
				echo "Usage: ./pubip.sh [-full]"
		fi
else
    wget http://ipecho.net/plain -O - -q ; echo
fi
