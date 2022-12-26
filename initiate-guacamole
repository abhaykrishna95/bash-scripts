#!/bin/bash
sudo apt-get update -y 
echo "Hi, I'm sleeping for 60 seconds..."
sleep 60
sudo docker run --rm guacamole/guacamole /opt/guacamole/bin/initdb.sh --mysql > initdb.sql
sudo docker cp initdb.sql mysqldb:/guac_db.sql
sudo docker exec -it mysqldb sh -c 'cat guac_db.sql | mysql -uroot -p"$MYSQL_ROOT_PASSWORD" guacamole_db'
echo "guacamole docker deployment successfully completed!!"
