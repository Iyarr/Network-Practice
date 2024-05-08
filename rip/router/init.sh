#! /bin/bash

sed -i 's/ripd=no/ripd=yes/' /etc/frr/daemons

# 設定ファイルの設定
echo "hostname $HOSTNAME" >> /etc/frr/vtysh.conf

/etc/init.d/frr start

touch /home/frr.init
echo "router rip
version $RIP_VERSION" >> /home/frr.init
# ホスト内のIFとIPアドレスを取得
ip address show | grep "scope global" | \
while read line; do
  # ブロードキャストアドレスを取得
  brd_address=$(echo "$line" | grep -oE 'brd\s[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}')
  # ブロードキャストアドレスが10.0.0.255か10.0.5.255の場合はRIPを有効にしない
  # 詳しくは rip.md の構成図を参照
  if [ "$brd_address" != "brd 10.0.0.255" ] && [ "$brd_address" != "brd 10.0.5.255" ]; then
    # インタフェース名を取得
    ifname=$(echo "$line" | grep -oE '[A-Za-z0-9]*$')
    echo "network $ifname" >> /home/frr.init
  else
    echo "network $ifname" >> /home/frr.init
  fi
done

vtysh -c "copy /home/frr.init running-config"

tail -f /dev/null

exit 0