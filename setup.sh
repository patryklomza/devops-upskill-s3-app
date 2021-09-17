#!/bin/bash
apt-get update && apt-get upgrade -y
apt-get install unzip -y
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
unzip /tmp/awscliv2.zip
/tmp/aws/install
apt-get install -y python3-pip
apt-get install -y python-is-python3
apt-get install -y nginx
git clone https://github.com/patryklomza/devops-upskill-s3-app.git /var/www/webApp
chown -R ubuntu /var/www/webApp
curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/install-poetry.py | python3 -
source /var/www/webApp/env.sh
poetry config virtualenvs.in-project true
cd /var/www/webApp && poetry install
cp /var/www/webApp/conf/upskill.service /etc/systemd/system/upskill.service
cp /var/www/webApp/conf/upskill /etc/nginx/sites-available/upskill
ln -s /etc/nginx/sites-available/upskill /etc/nginx/sites-enabled
systemctl start upskill
systemctl enable upskill
systemctl restart nginx
