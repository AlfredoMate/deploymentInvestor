#!/bin/bash

# Install Docker if not present
if ! command -v docker >/dev/null 2>&1; then
  sudo apt-get update -y
  sudo apt-get install -y docker.io
  sudo systemctl start docker
  sudo systemctl enable docker
fi

# Pull images
sudo docker pull alfredomate/investor:latest
sudo docker pull alfredomate/investor-frontend:latest

# Remove old containers if they exist
sudo docker rm -f backend || true
sudo docker rm -f frontend || true

# Wait for RDS to be ready (port 3306)
MAX_RETRIES=60
COUNT=0
until nc -z -v -w5 ${db_host} 3306
do
  COUNT=$((COUNT+1))
  echo "Waiting for RDS to be available..."
  sleep 5
  if [ $COUNT -ge $MAX_RETRIES ]; then
    echo "RDS did not become available in time!"
    exit 1
  fi
done

echo "RDS is ready, starting backend..."

# Start backend container
sudo docker run -d --name backend -p 8080:8080 --restart unless-stopped \
  -e DB_USERNAME=${db_username} \
  -e DB_PASSWORD=${db_password} \
  -e DB_HOST=${db_host} \
  -e DB_NAME=investor_db \
  alfredomate/investor:latest

# Wait a few seconds for backend to start
sleep 10

# Start frontend container
sudo docker run -d --name frontend -p 80:80 --restart unless-stopped \
  -e REACT_APP_API_URL=http://localhost:8080 \
  alfredomate/investor-frontend:latest