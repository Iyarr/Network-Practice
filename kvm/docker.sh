#!sh

docker stop kvm
docker rmi kvm:latest
docker build -t kvm:latest . --no-cache
docker run --rm --privileged -d --name kvm kvm:latest 
docker exec -it kvm sh

