#!/bin/bash
set -ex

LOG_FILE="/home/ubuntu/user_data_debug.log"
exec > >(tee -a $LOG_FILE) 2>&1

echo "=== Starting user_data.sh at $(date) ==="

# --- 1️⃣ Install Docker if not already installed ---
if ! command -v docker >/dev/null 2>&1; then
  echo "Docker not found. Installing..."
  sudo apt-get update -y
  sudo apt-get install -y docker.io
  sudo systemctl start docker
  sudo systemctl enable docker
else
  echo "Docker is already installed."
fi

# --- 2️⃣ Pull latest Docker images ---
echo "Pulling Docker images..."
sudo docker pull alfredomate/investor:latest
sudo docker pull alfredomate/investor-frontend:latest

# --- 3️⃣ Remove old containers if they exist ---
echo "Cleaning up old containers..."
sudo docker rm -f backend || true
sudo docker rm -f frontend || true

# --- 4️⃣ Wait for RDS to be available ---
MAX_RETRIES=60
COUNT=0
until nc -z -v -w5 "${db_host}" 3306; do
  COUNT=$((COUNT+1))
  echo "Waiting for RDS at ${db_host}:3306..."
  sleep 5
  if [ $COUNT -ge $MAX_RETRIES ]; then
    echo "RDS did not become available in time!"
    exit 1
  fi
done

echo "RDS is ready!"

# --- 5️⃣ Start backend container ---
echo "Starting backend container..."
sudo docker run -d --name backend -p 8080:8080 --restart unless-stopped \
  -e DB_USERNAME="${db_username}" \
  -e DB_PASSWORD="${db_password}" \
  -e DB_HOST="${db_host}" \
  -e DB_NAME="investor_db" \
  alfredomate/investor:latest

# Wait a few seconds to let backend initialize
sleep 10

# --- 6️⃣ Start frontend container ---
echo "Starting frontend container..."
sudo docker run -d --name frontend -p 80:80 --restart unless-stopped \
  -e REACT_APP_API_URL="http://localhost:8080" \
  alfredomate/investor-frontend:latest

echo "=== Finished user_data.sh at $(date) ==="