# Docker 関連

## Docker コンテナを起動するとすぐに終了してしまう

Docker コンテナを起動するとすぐに終了してしまう問題が生じた
原因は CMD で指定したコマンドが終了するとコンテナ自体も終了してしまうからだった

### Docker のプロセスの仕組み

Docker においてはコンテナ内の PID1 のプロセスが終了するとコンテナが停止してしまう
PID1 のプロセスは、全てのプロセスの直接的、又は間接的な親プロセスで子プロセスにリソースを継承させたり、操作をすることができる
そしてその PID1 のプロセスは Dockerfile で CMD にて指定する

> ちなみに CMD で指定したコマンドはバックグラウンドで実行されるのでコマンドに`&`をつける必要はない

### 通常の Linux では

通常は systemctl コマンド等が使えるようになる /sbin/init プロセスが PID1 として常時実行されている
Docker のコンテナ内ではこのプロセスが動作しないため、systemctl コマンド等が使えない

### コンテナを起動し続ける工夫

色々なサイトによると、終了しないコマンドを指定することでコンテナを起動し続けることができると書かれていた

```Dockerfile
CMD ["tail", "-f", "/dev/null"]
```

ただこれだけだとコンテナ内のプロセスは何も動作しないので FRRouting のセットアップをする処理が実行できない

### 解決策

シェルスクリプトを作成し、それを CMD で実行する
スクリプトの最後で`tail  -f /dev/null`コマンドを実行することでコンテナを起動し続けることができる

```Dockerfile
COPY ./frr.init /root/frr.init
CMD ["~/frr.init", "start"]
```

~/frr.init

```Bash
# FRRouting のインストール、初期設定など
tail -f /dev/null
```

## Dockerfile でcopyしてきたスクリプトを実行できない

Dockerfile から以下のコードによってコピーしたスクリプトを実行できない問題が発生した

```Dockerfile
COPY ./init.sh /home/init.sh
RUN chmod +x /home/init.sh

CMD ["/home/init.sh"]
```

`CMD`で指定したスクリプトの実行で以下のエラーが発生する

```
bash: /home/init.sh: cannot execute: required file not found
```
スクリプトの内容も簡単に書いておく
```bash
#! /bin/bash

# 処理内容は省略
tail /dev/null
exit 0
```

### 解決策

Windowsでの改行コードとLinux上での改行コードが違っていて実行ができていなかったため、dos2unixというコマンドを使用して変換することで解決した

```Dockerfile
COPY ./init.sh /home/init.sh
RUN chmod +x /home/init.sh && dos2unix /home/init.sh

CMD ["/home/init.sh"]
```