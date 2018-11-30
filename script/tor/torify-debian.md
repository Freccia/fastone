```
$ sudo -i
```

```
$ apt install tor apt-transport-tor
```

```
$ echo "net.ipv4.tcp_timestamps = 0" > /etc/sysctl.d/tcp_timestamps.conf
$ sysctl -p /etc/sysctl.d/tcp_timestamps.conf
```

```
$ nano /etc/default/grub
```

```
GRUB_CMDLINE_LINUX_DEFAULT="ipv6.disable=1 quiet"
```

```
$ update-grub
```

```
$ systemctl disable tor.service
```

```
$ nano /etc/apt/sources.list
```

```
deb tor+http://vwakviie2ienjx6t.onion/debian jessie main
deb-src tor+http://vwakviie2ienjx6t.onion/debian jessie main

deb tor+http://sgvtcaew4bxjd7ln.onion/debian-security jessie/updates main
deb-src tor+http://sgvtcaew4bxjd7ln.onion/debian-security jessie/updates main

# jessie-updates, previously known as 'volatile'
deb tor+http://vwakviie2ienjx6t.onion/debian jessie-updates main
deb-src tor+http://vwakviie2ienjx6t.onion/debian jessie-updates main
```

```
$ echo "alias apt-update='sudo systemctl start tor.service && sleep 10 && sudo apt update && sudo systemctl stop tor.service'" >> .bashrc
```

```
$ echo "alias dist-upgrade='sudo systemctl start tor.service && sleep 10 && sudo apt update && sudo apt dist-upgrade && sudo apt-get clean && sudo systemctl stop tor.service'" >> .bashrc
```

```
$ echo "function apt-install() { sudo systemctl start tor.service; sleep 10; sudo apt update; sudo apt install "\$@"; sudo apt-get clean; sudo systemctl stop tor.service; }" >> .bashrc
```

```
$ echo "function tordown() { sudo systemctl start tor.service; sleep 10; sudo torsocks wget -c "\$@"; sudo systemctl stop tor.service; }" >> .bashrc
```

```
$ source .bashrc
```