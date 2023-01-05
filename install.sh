#!/bin/bash
echo -e "go to https://tak.gov/products/tak-server\n"

echo -e "Download tak server .deb package: takserver_4.8-RELEASE31_all.deb\n"

read -p "Press enter to continue once you have downloaded .deb package is in cwd"

read -p "Enter Admin name:" admin

echo -e "Password must have at least 15 characters and must include 1 lowercase, 1 uppercase, 1 number and 1 special character."

read -p "Enter Admin password:" admin_pw

echo -e "* soft nofile 32768\n* hard nofile 32768" | sudo tee --append /etc/security/limits.conf > /dev/null

sudo curl -fsSo /etc/apt/trusted.gpg.d/pgdg.asc https://www.postgresql.org/media/keys/ACCC4CF8.asc

sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'

sudo apt update

sudo apt install netcat

sudo dpkg -i takserver_4.8-RELEASE31_all.deb

sudo apt --fix-broken install -y

sudo /opt/tak/db-utils/takserver-setup-db.sh

sudo systemctl daemon-reload

sudo systemctl start takserver

sudo systemctl enable takserver

echo -e "waiting for server to start\n"

while ! echo exit | nc localhost 8080 >/dev/null; do sleep 10; done

sudo java -jar /opt/tak/utils/UserManager.jar usermod -A -p $admin_pw $admin

echo -e "you can now access the server at http://ipaddress:8080"

echo -e "Added "$admin" with password of "$admin_pw

echo -e "install complete, next step certificates"

echo -e "Do not rerun this script to try to reinstall, it wont work right/will be unusable"
