#!/bin/bash

apt-get update -y
apt-get install -y docker.io

systemctl start docker
systemctl enable docker

# Pull images
docker pull alfredomate/investor:latest
docker pull alfredomate/investor-frontend:latest

# Remove old containers if they exist
docker rm -f backend || true
docker rm -f frontend || true

# Start backend container
docker run -d \
  --name backend \
  -p 8080:8080 \
  -e DB_USERNAME=${db_username} \
  -e DB_PASSWORD=${db_password} \
  -e DB_HOST=${db_host} \
  -e DB_NAME=investor_db \
  alfredomate/investor:latest

# Start frontend container
docker run -d \
  --name frontend \
  -p 80:80 \
  alfredomate/investor-frontend:latest