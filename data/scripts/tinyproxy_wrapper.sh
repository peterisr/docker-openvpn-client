#!/bin/ash
# shellcheck shell=ash
# shellcheck disable=SC2169 # making up for lack of ash support

echo -e "Running Tinyproxy HTTP proxy server.\n"

until ip link show tun0 2>&1 | grep -qv "does not exist"; do
    sleep 1
done

cp -fp /data/tinyproxy.conf /tmp/tinyproxy.conf

ETHS=$(ip -brief link show type veth | cut -d'@' -f1)
for eth in $ETHS; do
    addr_eth=$(ip a show dev "$eth" | grep inet | cut -d " " -f 6 | cut -d "/" -f 1)
    echo "Listen ${addr_eth}" >> /tmp/tinyproxy.conf
done

addr_tun=$(ip a show dev tun0 | grep inet | cut -d " " -f 6 | cut -d "/" -f 1)
echo "Bind ${addr_tun}" >> /tmp/tinyproxy.conf

tinyproxy -d -c /tmp/tinyproxy.conf
