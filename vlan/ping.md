# 内容

とりあえずコンテナを作り、ping コマンドが届くのかどうかを試したい

## ネットワーク構成

- 一つの compose にコンテナを二つ立ち上げてお互いに通信する
- Docker でのネットワーク構成の仕方を学習したい
- とりあえずコマンドをいじってみる

## 使用コマンド

### ip コマンド

- ip link

  - ネットワークインタフェースの表示

- ip addr show

  - ネットワークインタフェースとそれの Ip アドレスの表示

結果の読み方

- link/ether

  - mac アドレス

- inet

  - ipv4

- inet6
  - ipv6

## 起動後の操作

s1
ip route add 10.0.2.0/24 via 10.0.1.2 dev eth0

s2
ip route add 10.0.1.0/24 via 10.0.2.2 dev eth0
