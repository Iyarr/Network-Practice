#!sh

docker-compose down --rmi all --volumes

no_cache_up() {
    docker-compose build --no-cache
    docker-compose up -d
}

cache_up() {
    docker-compose build
    docker-compose up -d
}

if [ "$1" = "up" ]; then
    cache_up
elif [ "$1" = "no-cache" ]; then
    no_cache_up
fi


exit 0