#!/bin/bash
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg lsb-release -y
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo chmod a+r /etc/apt/keyrings/docker.gpg
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y
sudo usermod -aG docker $USER
sudo service docker start
sudo cat <<'EOF'>> docker-compose.yaml
version: "3.1"
services:
  mysqldb:
    image: mysql
    container_name: mysqldb
    environment:
      MYSQL_ROOT_PASSWORD: Pass@word88
      MYSQL_DATABASE: guacamole_db
      MYSQL_USER: guacamole_user
      MYSQL_PASSWORD: Pass@word88
    volumes:
      - guac-db-data:/var/lib/mysql
    restart: unless-stopped
  guacd:
    image: guacamole/guacd
    container_name: guacd
    ports:
      - 4822:4822
    restart: unless-stopped
  guacamole:
    image: guacamole/guacamole
    container_name: guacamole
    environment:
      GUACAMOLE_HOME: /opt/guacamole
      MYSQL_DATABASE: guacamole_db
      MYSQL_USER: guacamole_user
      MYSQL_PASSWORD: Pass@word88
      GUACD_HOSTNAME: guacd
      GUACD_PORT: 4822
      MYSQL_HOSTNAME: mysqldb
      MYSQL_PORT: 3306
      WEBAPP_CONTEXT: ROOT
      TOTP_ENABLED: true
    volumes:
      - guacamole-home:/opt/guacamole
    depends_on:
      - mysqldb
      - guacd
    ports:
      - 8080:8080
    restart: unless-stopped
volumes:
  guac-db-data:
  guacamole-home:
EOF
sudo docker compose up -d
sleep 30s
sudo docker run --rm guacamole/guacamole /opt/guacamole/bin/initdb.sh --mysql > initdb.sql
sudo docker cp initdb.sql mysqldb:/guac_db.sql
sudo docker exec -it mysqldb sh -c 'cat guac_db.sql | mysql -uroot -p"$MYSQL_ROOT_PASSWORD" guacamole_db'