#!/usr/bin/env bash

trap 'echo -e "Abort (rc: $?)"' 0

if [ "$(uname -s)" != "Linux" ] || 
    [ -z "$(uname -v) | grep 'Debian'" ];then
    echo "This script has to run on Debian Linux."
    exit 1
fi

set -o errexit
#set -o nounset
set -o pipefail

blue='\033[1;94m'
green='\033[1;92m'
red='\033[1;91m'
endc='\033[1;00m'

_backup_dir="/opt/tor-proxy"
_log_file="/tmp/tor-proxy.log"

#the UID that Tor runs as (varies from system to system)
_tor_uid="$(id -u debian-tor)"
_trans_port="9040"
_socks_port="9050"
_dns_port="5353"

#Tor's VirtualAddrNetworkIPv4
_virt_addr="10.192.0.0/10"

#LAN destinations that shouldn't be routed through Tor
#Check reserved block.
_non_tor="127.0.0.0/8 10.0.0.0/8 172.16.0.0/12 192.168.0.0/16"

#Other IANA reserved blocks (These are not processed by tor and dropped by default)
_resv_iana="0.0.0.0/8 100.64.0.0/10 169.254.0.0/16 192.0.0.0/24 192.0.2.0/24 192.88.99.0/24 198.18.0.0/15 198.51.100.0/24 203.0.113.0/24 224.0.0.0/3"

echo ""

if [ $(id -u) -ne 0 ]; then
    echo -e "$green[$red!$green]$red This script must be run as root$endc" >&2
    exit 1
fi


if ! [ -d $_backup_dir ]; then
    mkdir -p $_backup_dir
fi

usage () {

    echo -e "$green Usage:$blue tor-transparent-proxy [option] [interface]$endc" >&2
    echo -e "$green option:$blue start stop ...$endc" >&2
}

iptables-flush-all() {
	echo "Stopping firewall and allowing everyone..."
	ipt="/sbin/iptables"
	## Failsafe - die if /sbin/iptables not found
	[ ! -x "$ipt" ] && { echo "$0: \"${ipt}\" command not found."; exit 1; }
	$ipt -P INPUT ACCEPT
	$ipt -P FORWARD ACCEPT
	$ipt -P OUTPUT ACCEPT
	$ipt -F
	$ipt -X
	#$ipt -t nat -F
	#$ipt -t nat -X
	$ipt -t mangle -F
	$ipt -t mangle -X
	$ipt -t raw -F
	$ipt -t raw -X
}

edit_torrc () {

    cp -vf /etc/tor/torrc $_backup_dir/torrc.bak 

    echo -e "Log notice file $_log_file
    VirtualAddrNetworkIPv4 $_virt_addr
    AutomapHostsOnResolve 1
    TransPort $_trans_port
    DNSPort $_dns_port" > /etc/tor/torrc
}

edit_resolv_conf () {

    cp -vf /etc/resolv.conf $_backup_dir/resolv.conf.bak
    echo -e "nameserver 127.0.0.1" > /etc/resolv.conf
}

backup_iptables_rules () {

    #cp -vf /etc/iptables/rules.v4 $_backup_dir/rules.v4
    iptables-save > $_backup_dir/rules.v4
}

restore_torrc () {

    cp -vf $_backup_dir/torrc.bak /etc/tor/torrc
}

restore_resolv_conf () {

    cp -vf $_backup_dir/resolv.conf.bak /etc/resolv.conf
}

restore_iptables_rules () {

    #cp -vf $_backup_dir/rules.v4 /etc/iptables/rules.v4

    iptables-flush-all
    iptables-restore < $_backup_dir/rules.v4
}

tor_start () {

    if [ $# -lt 1 ]; then
        echo -e "$green[$red!$green]$red Please specify an interface.$endc" >&2
        echo -e "$green[$red!$green]$red Options: $endc" >&2
        usage
        exit 1
    fi

    # set output interface
    _out_if="$1"

    systemctl start tor

    edit_torrc
    edit_resolv_conf
    backup_iptables_rules

    echo -e "$red Are you using a server? (y/n) $endc"
    echo -e "$green Don't lock yourself out after the iptables flush $endc"
    read server
    shopt -s nocasematch
    if [[ $server == 'Y' ]] || [[ $server == 'Yes' ]]; then
        iptables -P INPUT ACCEPT
        iptables -P OUTPUT ACCEPT
    elif [[ $server != 'N' ]] && [[ $server != 'No' ]];then
        echo -e "$green[$red!$green]$red Mistyped. Abort.$endc" >&2
        exit 1
    fi
    shopt -u nocasematch

    ### flush iptables
    iptables -F
    #iptables -t nat -F


    ### WARNING :: these rules fix a leak on TCP CLOSE_WAIT
    ## https://lists.torproject.org/pipermail/tor-talk/2014-March/032503.html 
    ## https://lists.torproject.org/pipermail/tor-talk/2014-March/032507.html

    #iptables -A OUTPUT -m conntrack --ctstate INVALID -j LOG --log-prefix "Transproxy ctstate leak blocked: " --log-uid
    iptables -A OUTPUT -m conntrack --ctstate INVALID -j DROP
    iptables -A OUTPUT -m state --state INVALID -j LOG --log-prefix "Transproxy state leak blocked: " --log-uid
    iptables -A OUTPUT -m state --state INVALID -j DROP

    iptables -A OUTPUT ! -o lo ! -d 127.0.0.1 ! -s 127.0.0.1 -p tcp -m tcp --tcp-flags ACK,FIN ACK,FIN -j LOG --log-prefix "Transproxy leak blocked: " --log-uid
    iptables -A OUTPUT ! -o lo ! -d 127.0.0.1 ! -s 127.0.0.1 -p tcp -m tcp --tcp-flags ACK,RST ACK,RST -j LOG --log-prefix "Transproxy leak blocked: " --log-uid
    iptables -A OUTPUT ! -o lo ! -d 127.0.0.1 ! -s 127.0.0.1 -p tcp -m tcp --tcp-flags ACK,FIN ACK,FIN -j DROP
    iptables -A OUTPUT ! -o lo ! -d 127.0.0.1 ! -s 127.0.0.1 -p tcp -m tcp --tcp-flags ACK,RST ACK,RST -j DROP


    ### set iptables *nat
    #nat .onion addresses
    iptables -t nat -A OUTPUT -d $_virt_addr -p tcp -m tcp --tcp-flags FIN,SYN,RST,ACK SYN -j REDIRECT --to-ports $_trans_port

    #nat dns requests to Tor
    iptables -t nat -A OUTPUT -d 127.0.0.1/32 -p udp -m udp --dport 53 -j REDIRECT --to-ports $_dns_port

    #don't nat the Tor process, the loopback, or the local network
    iptables -t nat -A OUTPUT -m owner --uid-owner $_tor_uid -j RETURN
    iptables -t nat -A OUTPUT -o lo -j RETURN

    for _lan in $_non_tor; do
        iptables -t nat -A OUTPUT -d $_lan -j RETURN
    done

    for _iana in $_resv_iana; do
        iptables -t nat -A OUTPUT -d $_iana -j RETURN
    done

    #redirect whatever fell thru to Tor's TransPort
    iptables -t nat -A OUTPUT -p tcp -m tcp --tcp-flags FIN,SYN,RST,ACK SYN -j REDIRECT --to-ports $_trans_port

    ### set iptables *filter
    #*filter INPUT
    iptables -A INPUT -m state --state ESTABLISHED -j ACCEPT
    iptables -A INPUT -i lo -j ACCEPT

    #Don't forget to grant yourself ssh access for remote machines before the DROP.
    #iptables -A INPUT -i $_out_if -p tcp --dport 22 -m state --state NEW -j ACCEPT

    iptables -A INPUT -j DROP

    #*filter FORWARD
    iptables -A FORWARD -j DROP

    #*filter OUTPUT
    #possible leak fix. See warning.
    iptables -A OUTPUT -m state --state INVALID -j DROP

    iptables -A OUTPUT -m state --state ESTABLISHED -j ACCEPT

    #allow Tor process output
    iptables -A OUTPUT -o $_out_if -m owner --uid-owner $_tor_uid -p tcp -m tcp --tcp-flags FIN,SYN,RST,ACK SYN -m state --state NEW -j ACCEPT

    #allow loopback output
    iptables -A OUTPUT -d 127.0.0.1/32 -o lo -j ACCEPT

    #tor transproxy magic
    iptables -A OUTPUT -d 127.0.0.1/32 -p tcp -m tcp --dport $_trans_port --tcp-flags FIN,SYN,RST,ACK SYN -j ACCEPT

    #allow access to lan hosts in $_non_tor
    #these 3 lines can be ommited
    for _lan in $_non_tor; do
        iptables -A OUTPUT -d $_lan -j ACCEPT
    done

    #Log & Drop everything else.
    iptables -A OUTPUT -j LOG --log-prefix "Dropped OUTPUT packet: " --log-level 7 --log-uid
    iptables -A OUTPUT -j DROP

    #Set default policies to DROP
    iptables -P INPUT DROP
    iptables -P FORWARD DROP
    iptables -P OUTPUT DROP

}

tor_stop () {

    systemctl stop tor

    restore_torrc
    restore_resolv_conf
    restore_iptables_rules
}

status()
{
	echo "To check leaks:"
	echo '$ ss -ntp | grep `cat /var/run/tor/tor.pid`'
	echo '$ tcpdump -n -f -p -i eth0 not arp and not host IP.TO.TOR.GUARD'
	echo
	echo "Current ip address:"
	wget http://ipecho.net/plain -O - -q ; echo
}

case "$1" in
    start)
        tor_start $2
        ;;
    stop)
        tor_stop
        ;;
    change)
        change
        # TODO
        echo "Not implemented yet."
        ;;
    status)
        status
        ;;
    change_mac)
	# TODO
	echo "Not implemented yet."
        change_mac
        ;;
    status_mac)
	# TODO
	echo "Not implemented yet."
        status_mac
        ;;
    *)
        usage
        exit 1
        ;;
esac

echo -e $endc

trap : 0


