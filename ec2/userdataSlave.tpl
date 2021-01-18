#!/bin/bash

exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
sudo apt-get update
sudo apt install -y postgresql postgresql-contrib
sudo pg_ctlcluster 12 main start

echo "listen_addresses = '*'" | sudo tee -a /etc/postgresql/12/main/postgresql.conf
sudo tee -a /etc/postgresql/12/main/pg_hba.conf <<< "host    all             all             0.0.0.0/0        trust"
sudo tee -a /etc/postgresql/12/main/pg_hba.conf <<< "host    all             all             ::/0                   md5"
sudo /etc/init.d/postgresql restart
sudo service postgres restart

#sudo -i -u postgres psql -c "CREATE DATABASE books"
#sudo -i -u postgres psql -c "CREATE USER user1 WITH ENCRYPTED PASSWORD 'user1234'"
#sudo -i -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE books TO user1"
sudo -i -u postgres psql -c "ALTER USER postgres PASSWORD 'user1234'"

sudo -i -u postgres psql -c "CREATE TABLE IF NOT EXISTS Livres (Livre_ID SERIAL PRIMARY KEY, TITRE VARCHAR(100) NOT NULL, Auteur VARCHAR(100) NOT NULL, Commentaires TEXT);"
sudo -i -u postgres psql -c "INSERT INTO Livres (Livre_ID, Titre, Auteur, Commentaires) VALUES (1, 'Mrs. Bridge', 'Evan S. Connell', 'Premier de la série'), (2, 'Mr. Bridge', 'Evan S. Connell', 'Second de la série'), (3, 'L''ingénue libertine', 'Colette', 'Minne + Les égarements de Minne') ON CONFLICT DO NOTHING;"
