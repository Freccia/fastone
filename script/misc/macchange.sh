#!/bin/bash
service network-manager stop
ifconfig eth0 down
macchanger -r eth0
ifconfig eth0 up
ifconfig wlan0 down
macchanger -r wlan0
ifconfig wlan0 up
service network-manager start
