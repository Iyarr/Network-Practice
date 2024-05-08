# Frrouting

今回の学習で Frrouting という OSS を使うことにしたので、今回どのような手順で進めていったのかや、身についた知識を書いておく

## 使用する経緯

ネットワークの学習をするために仮想的なルーターを Docker コンテナ内に構築する必要があったので使おうと思った

## 作業内容

### Docker コンテナを起動するとすぐに終了してしまう

Docker コンテナを起動するとすぐに終了してしまう問題が生じた
原因は CMD で指定したコマンドが終了するとコンテナ自体も終了してしまうからだった

#### Docker のプロセスの仕組み

Docker においてはコンテナ内の PID1 のプロセスが終了するとコンテナが停止してしまう
PID1 のプロセスは、全てのプロセスの直接的、又は間接的な親プロセスで子プロセスにリソースを継承させたり、操作をすることができる
そしてその PID1 のプロセスは Dockerfile で CMD にて指定する

> ちなみに CMD で指定したコマンドはバックグラウンドで実行されるのでコマンドに`&`をつける必要はない

#### 通常の Linux では

通常は systemctl コマンド等が使えるようになる /sbin/init プロセスが PID1 として常時実行されている
Docker のコンテナ内ではこのプロセスが動作しないため、systemctl コマンド等が使えない

#### コンテナを起動し続ける工夫

色々なサイトによると、終了しないコマンドを指定することでコンテナを起動し続けることができると書かれていた

```Dockerfile
CMD ["tail", "-f", "/dev/null"]
```

ただこれだけだとコンテナ内のプロセスは何も動作しないので FRRouting のセットアップをする処理が実行できない

#### 解決策

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

### Frr のインストール

#### apt install

まず apt install でインストールしようとしたが、パッケージが見つからないようだった

```bash
apt install frr
```

これだけではインストールできないようだった

#### 公式サイトの手順

公式サイトに手順が書いてあったのでそれに従ってインストールした
URL: [https://github.com/FRRouting/frr/releases](https://github.com/FRRouting/frr/releases)

```bash
apt install -y curl lsb-release gnupg
# ここから公式のコマンド
# add GPG key
curl -s https://deb.frrouting.org/frr/keys.gpg | sudo tee /usr/share/keyrings/frrouting.gpg > /dev/null

# possible values for FRRVER: frr-6 frr-7 frr-8 frr-9.0 frr-9.1 frr-stable
# frr-stable will be the latest official stable release
FRRVER="frr-stable"
echo deb '[signed-by=/usr/share/keyrings/frrouting.gpg]' https://deb.frrouting.org/frr \
     $(lsb_release -s -c) $FRRVER | sudo tee -a /etc/apt/sources.list.d/frr.list

# update and install FRR
sudo apt update && sudo apt install frr frr-pythontools
```

サイトからコピーしただけだと味気ないので、他の方法インストールできないか模索してみることにした

#### Docker Hub からイメージを取得

frrouting/frr という Alpine Linux ベースのイメージが Docker Hub に公開されている
インストールすることができるようだが、自力でインストールしたいので却下

#### ソースからビルド

Github からソースを取得してビルドする方法を試してみることにした

```bash

apt install -y git autoconf automake libtool  wget
git clone https://github.com/FRRouting/frr.git
cd frr
# 使うバージョンのブランチを指定
git branch stable/9.0 origin/stable/9.0
git checkout stable/9.0
git pull origin stable/9.0
./bootstrap.sh
wget https://www.python.org/ftp/python/3.11.1/Python-3.11.1.tar.xz
tar xJf Python-3.11.1.tar.xz
```

ここまで作業として進めたが、依存関係のあるパッケージが他にもたくさんあることがわかり、これ以上はビルドに時間がかかるので却下

最終的には公式サイトの手順でFRRoutingをセットアップすることにした

### frr の起動

Frrouting はデーモンとして動作するため、まずは起動する必要がある
しかし、Docker上で使用していることで起動する方法によって初期設定ができないものがあった
公式サイトを参考に起動方法を模索した

#### 起動するコマンドを CMD で指定する

Dockerfile に以下のように記述する

```Dockerfile
CMD ["/etc/init.d/frr", "start"]
```

この場合、初期設定ができないし、このコマンドの実行自体はすぐに終わるので、コンテナが終了してしまう

> CMD で指定したコマンドは PID 1 で動作するため、処理が終了するとコンテナが終了する。コンテナ以外では systemd が PID 1 で動作しているため、systemctl が使える

#### コンテナ内で systemd を起動する

公式サイトによると以下のコマンドを実行する必要があった

```bash
systemctl start frr
```

よって systemctl を使えるようにすることで frr を起動できると考えた

```Bash
apt intall -y systemd
systemctl restart frr

```

しかし、systemctl は PID 1 で systemd が動作してないといけないため、Docker コンテナでは使えない
（具体的にはできるが、よくわかっていない段階で使いたくない）
では、systemd を起動する実行ファイルを指定して起動できるのではないかと考えた

```Dockerfile
apt intall -y systemd
CMD ["/sbin/init"]

```

しかし、コンテナを作成した際に`/sbin/init`が見つからないというエラーが出た
これはちょっと仕組みがわかっていないので断念した

#### CMD でシェルスクリプトを作成して実行する

CMD でシェルスクリプトを実行することで、frr を起動して、初期設定も行うことができると考えた

```Dockerfile
CMD ["~/.init.sh", "start"]
```

```bash

/etc/init.d/frr start
# 初期設定

tail -f /dev/null
```

何とかうまくいった。しかし、マルチラインの vtysh へのコマンド指定がうまくいかなかった

### Frr の初期設定

Frr において設定した内容をコンテナを起動した際に自動で設定させたいと考えた

#### /etc/frr/frr.conf に設定を記述

設定用のファイルに設定を直接書きこみ、コンテナを起動する際に読み込むようにする方法
手動で設定を一回確認しながら入力していき、最終的にファイルに書き込む

手動の設定を /etc/frr/frr.conf ファイルに反映したいとき配下のコマンドを使用する
（vtysh 内では `write integrated` コマンドを使用する）

```bash
vtysh -w
```

#### Lua で設定を記述

Lua というプログラミング言語を使用して設定を読み込ませる方法。
言語の難易度自体は高くないが、あまり慣れていないやり方になる

#### copy コマンドによる設定ファイルのコピー

vtysh で`copy /file running-config`コマンドを使用することで`/file`に指定したファイルに書かれている設定を反映させるコマンド
これまで作業しているが、特に支障はない

```bash
# /root/frr.init に設定内容を記述
echo "hostname router0" >> /root/frr.init
# 設定内容を反映
vtysh -c "copy /root/frr.conf running-config"
```

> 現在は**copy コマンドによる設定ファイルのコピー**によって設定を反映させている