sudo nano setup.sh
Copy script in via the clipboard

# Mark the script as executable
chmod +x setup.sh

run script like this to run as sudo:
sudo ./setup.sh

//Usefull if automating mysql_secure_setup

UNINSTALL COMPONENT 'file://component_validate_password';
SET GLOBAL validate_password_policy = 0;


# Se what is stored in debconf:
debconf-show mysql-community-server

debconf-get-selections
sudo debconf-get-selections | grep mysql

If you made a mistake, and you want to start over, don’t forget to purge the debconf database for the MySQL server:

echo PURGE | sudo debconf-communicate mysql-community-server
sudo apt purge mysql-client mysql-server
