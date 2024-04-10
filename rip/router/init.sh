#! /bin/bash

sed -i 's/ripd=no/ripd=yes/' /etc/frr/daemons

# 設定ファイルの設定
echo "hostname $HOSTNAME" >> /etc/frr/vtysh.conf

# frr.conf ファイルに追記
echo "!
router rip
 version $RIP_VERSION
exitopp
!" >> /etc/frr/frr.conf

/etc/init.d/frr start

touch /home/address.txt
touch /home/ifname.txt
# ホスト内のIFとIPアドレスを取得
ip address show | grep "scope global" | \
while read line; do
    # 正規表現でIF名とIPアドレスを取得
    echo "$line" | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}\/[0-9]{1,2}' >> /home/address.txt
    echo "$line" | grep -oE '[A-Za-z0-9]*$' >> /home/ifname.txt
    # echo "10.0.2.2/24" | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}\/[0-9]{1,2}'
    # echo "inet 10.0.0.2/24 brd 10.0.0.255 scope global eth0" | grep -oE '[A-Za-z0-9]*$'
done

tail -f /dev/null

exit 0