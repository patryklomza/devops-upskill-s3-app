#!/bin/bash
apt-get update && sudo apt-get upgrade -y
apt-get install -y python3-pip
apt-get install -y python-is-python3
apt-get install -y nginx
git clone https://github.com/patryklomza/devops-upskill-s3-app.git /var/www/webApp
chown -R ubuntu /var/www/webApp
curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/install-poetry.py | python3 -
source /var/www/webApp/env.sh
poetry install
cp ./conf/upskill.service /etc/systemd/system/upskill.service
cp ./conf/upskill /etc/nginx/sites-available/upskill
ln -s /etc/nginx/sites-available/upskill /etc/nginx/sites-enabled
systemctl start upskill
systemctl enable upskill
systemctl restart nginx
