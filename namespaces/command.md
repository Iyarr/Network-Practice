# command 集

- docker ps
- docker start
- docker create
- docker attach
- docker restart
- docker pause
  - コンテナ内のすべてのプロセスを一時停止する
- docker unpause
  - 再開させる
- docker stop
  - コンテナを停止、終了する
- docker kill
  - コンテナを終了させる（stop の上位互換）
- docker rm
- docker rmi
- docker images
- docker pull
- docker import
- docker build -t ${image_name}:${tag} ${path}
- docker run -d --name ${container_name} ${image_name}:${tag}
- docker exec -it ${container_name} bash
- docker commit
- docker network connect
- docker network create
- docker status
  - docker の状態を確認

## この Dockerfile 内で使用するコマンド

docker build -t space:latest .
docker run --privileged -d --name space space:latest
docker exec -it space bash
