
docker-compose down --rmi all --volumes

up () {
    docker-compose up -d
    if [ $? -eq 0 ]; then
        docker-compose exec "$1" bash
    fi
}

no_cache_up() {
    docker-compose build --no-cache
    if [ $? -eq 0 ]; then
        up "$1"
    fi
}

cache_up() {
    docker-compose build
    if [ $? -eq 0 ]; then
        up "$1"
    fi
}

if [ "$1" = "up" ]; then
    cache_up "$2"
elif [ "$1" = "no-cache" ]; then
    no_cache_up "$2"
fi

exit 0