#!/bin/bash

exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

sudo apt-get update
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh | bash
sudo . ~/.nvm/nvm.sh
nvm install --lts
sudo apt install -y npm

sudo git clone https://gitlab.com/picou75/arinf-proj.git

cd arinf-proj
sudo npm install
sudo npm install forever -g

db_password=user1234
db_database=postgres
db_user=postgres
db_port=5432

ip_master=${master}

echo "DB_HOST=$ip_master
DB_PASSWORD=$db_password
DB_DATABASE=$db_database
DB_USER=$db_user
DB_PORT=$db_port" >> .env

forever start index.js
