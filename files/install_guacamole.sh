#!/bin/bash
set -e

# --- Configuration ---
PROJECT_DIR="guacamole-docker"
DB_PASSWORD=$(openssl rand -base64 24) # Generate a secure random password

# --- Setup ---
echo "Creating directory '$PROJECT_DIR' for Guacamole..."
mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"

echo "Directory created. CWD is now $(pwd)"
echo ""

# --- Create .env file ---
echo "Generating .env file for database password..."
cat << EOF > .env
# This file stores secrets for your Guacamole stack
# Do not delete or share it!
GUAC_DB_PASSWORD=${DB_PASSWORD}
EOF
echo ".env file created."
echo ""

# --- Create docker-compose.yml file ---
echo "Generating docker-compose.yml file..."
cat << EOF > docker-compose.yml
version: '3.8'

services:
  guacd:
    image: guacamole/guacd
    container_name: guacd
    restart: unless-stopped
    volumes:
      - guac-drive:/drive
      - guac-record:/record
    networks:
      - guac-net

  postgres:
    image: postgres:15
    container_name: guac-postgres
    restart: unless-stopped
    volumes:
      - guac-db-data:/var/lib/postgresql/data
      - guac-init-vol:/docker-entrypoint-initdb.d
    environment:
      POSTGRES_DB: guacamole_db
      POSTGRES_USER: guacamole_user
      POSTGRES_PASSWORD: \${GUAC_DB_PASSWORD} # Reads from .env file
    networks:
      - guac-net

  # This container runs ONCE to create the database schema
  init-db:
    image: guacamole/guacamole
    command: >
      sh -c "
        echo 'Waiting for PostgreSQL to be ready...' &&
        /opt/guacamole/bin/initdb.sh --postgres > /init/initdb.sql &&
        echo 'Database init script created.'
      "
    volumes:
      - guac-init-vol:/init
    depends_on:
      - postgres
    networks:
      - guac-net

  guacamole:
    image: guacamole/guacamole
    container_name: guacamole
    restart: unless-stopped
    ports:
      - "8080:8080" # Access at http://localhost:8080/guacamole/
    environment:
      GUACD_HOSTNAME: guacd
      POSTGRES_HOSTNAME: postgres
      POSTGRES_DATABASE: guacamole_db
      POSTGRES_USER: guacamole_user
      POSTGRES_PASSWORD: \${GUAC_DB_PASSWORD} # Reads from .env file
    depends_on:
      - guacd
      - init-db # Waits for the init script to be created
    networks:
      - guac-net

networks:
  guac-net:
    driver: bridge

volumes:
  guac-db-data: # For PostgreSQL data
  guac-init-vol: # For the init script
  guac-drive: # For RDP drive sharing
  guac-record: # For session recording
EOF
echo "docker-compose.yml created."
echo ""

# --- Pull and Start ---
echo "Pulling all required Docker images... (This may take a moment)"
docker compose pull

echo ""
echo "Starting the Guacamole stack..."
docker compose up -d

echo ""
echo "--------------------------------------------------------"
echo "✅ Guacamole deployment started!"
echo ""
echo "It may take 1-2 minutes for the services to initialize."
echo ""
echo "Access Guacamole at: http://<YOUR_SERVER_IP>:8080/guacamole/"
echo ""
echo "Default login (CHANGE IMMEDIATELY):"
echo "  Username: guacadmin"
echo "  Password: guacadmin"
echo "--------------------------------------------------------"
