SHELL := /bin/bash
setup:
	sudo apt-get update && sudo apt-get upgrade -y
	sudo apt-get install -y python3-pip
	sudo apt-get install -y python-is-python3
	sudo apt-get install -y nginx
	curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/install-poetry.py | python3 -
	export PATH="/home/ubuntu/.local/bin:$PATH"
	poetry install
	sudo cp ./conf/upskill.service /etc/systemd/system/upskill.service
	sudo cp ./conf/upskill /etc/nginx/sites-available/upskill
	sudo ln -s /etc/nginx/sites-available/upskill /etc/nginx/sites-enabled
	sudo systemctl start upskill
	sudo systemctl enable upskill
	sudo systemctl restart nginx
