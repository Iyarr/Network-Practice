#! /bin/bash


router_init() {
    iptables -A FORWARD -j ACCEPT
    netfilter-persistent save
    netfilter-persistent reload
}

host1_init() {
    ip route add 10.0.2.0/24 via 10.0.1.2 dev eth0
}

host2_init() {
    ip route add 10.0.1.0/24 via 10.0.2.2 dev eth0
}

if [ "$1" = "router" ]; then
    router_init
elif [ "$1" = "host1" ]; then
    host1_init
elif [ "$1" = "host2" ]; then
    host2_init
fi

tail -f /dev/null