#!/bin/bash

#set this variables according your needs.
WIFI_SSID=<your ssid>
WIFI_PASSWD=<your wifi password>_
PASSWD_ROOT_MYSQL=<password for mysql root and for owncloud database user>
UUID_DISK=<uuid of your disk>


clear
echo "Connecting to OpenSoftware1"
sudo nmcli device wifi connect "$WIFI_SSID" password "$WIFI_PASSWD" ifname wlan0
if [ $? -eq 0 ]; then
	echo "CHIP are connected to wifi network...";
else
	echo "Connection to wifi failed... stopping the installation.";
	exit 1;
fi

echo "Updating apt databases...";
sudo apt update 
if [ $? -eq 0 ]; then
	echo "apt databases updated...";
else
	echo "This step failed... stopping the installation.";
	exit 1;
fi

echo "Installing ssh server...";
sudo apt install -y ssh 
if [ $? -eq 0 ]; then
	echo "SSH server installed succesfully...";
else
	echo "Installation of ssh failed... stopping the installation.";
	exit 1;
fi

echo "Installing locale"
sudo apt install locales && sudo dpkg-reconfigure locales && sudo locale-gen
if [ $? -eq 0 ]; then
	echo "locales installed...";
else
	echo "This step failed... stopping the installation.";
	exit 1;
fi

echo "Setting up avahi"
echo "<!DOCTYPE service-group SYSTEM \"avahi-service.dtd\">" > /etc/avahi/services/afpd.service
echo "<service-group>" >> /etc/avahi/services/afpd.service
echo "<name replace-wildcards=\"yes\">%h</name>" >> /etc/avahi/services/afpd.service
echo "<service>" >> /etc/avahi/services/afpd.service
echo "<type>_afpovertcp._tcp</type>" >> /etc/avahi/services/afpd.service
echo "<port>548</port>" >> /etc/avahi/services/afpd.service
echo "</service>" >> /etc/avahi/services/afpd.service
echo "</service-group>" >> /etc/avahi/services/afpd.service
sudo /etc/init.d/avahi-daemon restart
if [ $? -eq 0 ]; then
	echo "Avahi setted up and restarted...";
else
	echo "This step failed... stopping the installation.";
	exit 1;
fi

echo "Installing  mysqlserver"
echo mysql-server-5.1 mysql-server/root_password password  "$PASSWD_ROOT_MYSQL" | debconf-set-selections
echo mysql-server-5.1 mysql-server/root_password_again password "$PASSWD_ROOT_MYSQL" | debconf-set-selections
sudo apt install -y mysql-server 
if [ $? -eq 0 ]; then
	echo "Mysql server installed...";
else
	echo "This step failed... stopping the installation.";
	exit 1;
fi

echo "Installing owncloud"
sudo apt install -y owncloud 
if [ $? -eq 0 ]; then
	echo "Owncloud installed...";
else
	echo "This step failed... stopping the installation.";
	exit 1;
fi

echo "Creating database $OWNCLOUD"
echo "CREATE DATABASE owncloud;" > yourfile.sql
echo "CREATE USER owncloud@localhost IDENTIFIED BY '$PASSWD_ROOT_MYSQL';" >> yourfile.sql
echo "GRANT ALL PRIVILEGES ON owncloud.* TO owncloud@localhost;" >> yourfile.sql
echo "flush privileges;" >> yourfile.sql
mysql -u root --password=$PASSWD_ROOT_MYSQL < yourfile.sql
if [ $? -eq 0 ]; then
	echo "owncloud database created...";
else
	echo "This step failed... stopping the installation.";
	exit 1;
fi

echo "Setting up owncloud disk..."
sudo mkdir /media/owncloud
echo "UUID=$UUID_DISK /media/owncloud vfat auto,users,uid=33,gid=33,dmask=027,fmask=137,utf8 0 0" >> /etc/fstab
if [ $? -eq 0 ]; then
	echo "/etc/fstab file configured...";
else
	echo "This step failed... stopping the installation.";
	exit 1;
fi

sudo mount -a
if [ $? -eq 0 ]; then
	echo "Mounting disk for owncloud...";
else
	echo "This step failed... stopping the installation.";
	exit 1;
fi

echo "Congratulations you already have you owncloud"
echo "Now follow the instructions below to configure you owncloud"
echo "+---------------------------------------------------------------------+"
echo "| On your laptop open a web browser and surf over to your C.H.I.P.    |"
echo "| at HOSTNAME.local/owncloud. Replace HOSTNAME with what you called   |"
echo "| your C.H.I.P. in Step 3. Then simply fill out all the input fields  |"
echo "| and your setup is done.                                             |"
echo "+---------------------------------------------------------------------+"
echo "| Username; pick whatever you want                                    |"
echo "| Password; pick whatever you want                                    |"
echo "| Data folder; /media/owncloud/                                       |"
echo "| Username; owncloud                                                  |"
echo "| Password; YOUR_DB_PASSWORD from Step 4                              |"
echo "| Database; owncloud                                                  |"
echo "| Host; localhost                                                     |"
echo "+---------------------------------------------------------------------+"








