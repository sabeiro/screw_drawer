#sudo usermod -a -G www-data sabeiro
#sudo adduser sabeiro www-data
sudo chown -R sabeiro:www-data $1
sudo find $1 -type f -exec chmod 644 {} \;
sudo find $1 -type d -exec chmod 755 {} \;

