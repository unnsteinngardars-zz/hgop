echo "TAG=$1" > .env
docker-compose down
docker-compose up -d --build
