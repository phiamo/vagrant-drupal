sudo apt-get update
sudo sed -i "s/www-data/vagrant/g" /etc/apache2/envvars 
sudo apache2ctl stop
sudo rm -rf /var/lock/apache2
sudo apache2ctl start
exit 0
