#! /bin/bash

# デフォルトゲートウェイの設定
ip route replace default via $DEFAULT_IP dev eth0

tail -f /dev/null

exit 0