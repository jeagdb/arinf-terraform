#!/bin/bash

exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

sudo apt-get update
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh | bash
sudo . ~/.nvm/nvm.sh
nvm install node
sudo apt install -y npm

sudo git clone https://gitlab.com/picou75/urlReducer.git

cd urlReducer/front
sudo npm install
sudo npm run-script build
cp dist/* ../back/src/build
cd ../back
npm install
npm install forever -g
forever start src/server.js
