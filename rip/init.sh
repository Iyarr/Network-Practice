#! /bin/bash


router_init() {
    
}

host_init() {
    destination_ip="$2"
    ip route add default via "$destination_ip"
}

if [ "$1" = "router" ]; then
    router_init
elif [ "$1" = "host" ]; then
    host_init
fi

tail -f /dev/null