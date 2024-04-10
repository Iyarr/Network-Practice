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
# ホスト内のIFとIPアドレスを取得
ip address show | grep "scope global" | \
while read line; do
    # 正規表現でIF名とIPアドレスを取得
    # (?:\d{1,3}\.){3}: 非キャプチャグループで1~3桁の数字と.を3回繰り返す
    # \d{1,3}: 1~3桁の数字
    # \b: 単語境界
    echo "$line" >> /home/address.txt
done

tail -f /dev/null

exit 0