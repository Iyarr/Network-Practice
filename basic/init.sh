#! /bin/bash

router_init() {
    iptables -A FORWARD -j ACCEPT
    netfilter-persistent save
    netfilter-persistent reload
}

host_init() {
    # $1は関数として渡された引数
    destinatin_ip=$1
    ip route replace default via $destinatin_ip dev eth0
}

if [ "$1" = "router" ]; then
    router_init
elif [ "$1" = "host" ]; then
    # 関数は引数を取れないので、引数を渡すためには別途変数を定義する必要がある
    host_init "$2"
fi

tail -f /dev/null