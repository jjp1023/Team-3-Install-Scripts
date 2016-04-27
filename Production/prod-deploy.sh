#!/bin/bash -p

# Usage: bash <(curl -s https://raw.githubusercontent.com/ITMT-430/Team-3-Install-Scripts/master/Production/prod-deploy.sh)

#---------------------------Base System Install - should be run on every system------------------------------
apt-get update
apt-get install -y curl
apt-get install -y git
apt-get install -y vim
apt-get install -y zsh
#sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
git clone git://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh
cp ~/.zshrc ~/.zshrc.orig
mkdir /bs
cd /bs
git clone https://github.com/thegeekkid/zshconfig.git
cd zshconfig
git checkout teamproject
cp terminalparty.zsh-theme ~/.oh-my-zsh/themes/terminalparty.zsh-theme
cp zshrc ~/.zshrc
apt-get install -y apache2
apt-get install -y build-essential
apt-get install -y php5
apt-get install -y php5-dev
apt-get install -y php-pear
pear channel-discover pear.phing.info
pear install phing/phing
pear install VersionControl_Git-alpha
#---------------------------------------End Base System Install----------------------------------------------

#-------------------------------------------Vagrant copy-----------------------------------------------------

# This portion adapted from https://gist.github.com/rrosiek/8190550


# Variables
APPENV=local
DBHOST=localhost
DBNAME=irl
DBUSER=root
DBPASSWD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)

echo -e "\n--- Mkay, installing now... ---\n"
apt-get install -y debconf-utils

echo -e "\n--- Updating packages list ---\n"
apt-get -qq update

echo -e "\n--- Install base packages ---\n"
apt-get -y install vim curl build-essential python-software-properties git > /dev/null 2>&1

echo -e "\n--- Add some repos to update our distro ---\n"
add-apt-repository ppa:ondrej/php5 > /dev/null 2>&1
add-apt-repository ppa:chris-lea/node.js > /dev/null 2>&1

echo -e "\n--- Updating packages list ---\n"
apt-get update

echo -e "\n--- Install MySQL specific packages and settings ---\n"
echo "mysql-server mysql-server/root_password password $DBPASSWD" | debconf-set-selections
echo "mysql-server mysql-server/root_password_again password $DBPASSWD" | debconf-set-selections
echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | debconf-set-selections
echo "phpmyadmin phpmyadmin/app-password-confirm password $DBPASSWD" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/admin-pass password $DBPASSWD" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/app-pass password $DBPASSWD" | debconf-set-selections
echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect none" | debconf-set-selections
apt-get -y install mysql-server-5.5 phpmyadmin

echo -e "\n--- Setting up our MySQL user and db ---\n"
mysql -uroot -p$DBPASSWD -e "CREATE DATABASE $DBNAME"
mysql -uroot -p$DBPASSWD -e "grant all privileges on $DBNAME.* to '$DBUSER'@'localhost' identified by '$DBPASSWD'"

echo -e "\n--- Installing PHP-specific packages ---\n"
apt-get -y install php5 apache2 libapache2-mod-php5 php5-curl php5-gd php5-mcrypt php5-mysql php-apc > /dev/null 2>&1

echo -e "\n--- Enabling mod-rewrite ---\n"
a2enmod rewrite > /dev/null 2>&1

echo -e "\n--- Allowing Apache override to all ---\n"
sed -i "s/AllowOverride None/AllowOverride All/g" /etc/apache2/apache2.conf


#for testing
#echo -e "\n--- We definitly need to see the PHP errors, turning them on ---\n"
#sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php5/apache2/php.ini
#sed -i "s/display_errors = .*/display_errors = On/" /etc/php5/apache2/php.ini

echo -e "\n--- Turn off disabled pcntl functions so we can use Boris ---\n"
sed -i "s/disable_functions = .*//" /etc/php5/cli/php.ini

echo -e "\n--- Configure Apache to use phpmyadmin ---\n"
echo -e "\n\nListen 81\n" >> /etc/apache2/ports.conf
cat > /etc/apache2/conf-available/phpmyadmin.conf << "EOF"
<VirtualHost *:81>
    ServerAdmin webmaster@localhost
    DocumentRoot /usr/share/phpmyadmin
    DirectoryIndex index.php
    ErrorLog ${APACHE_LOG_DIR}/phpmyadmin-error.log
    CustomLog ${APACHE_LOG_DIR}/phpmyadmin-access.log combined
</VirtualHost>
EOF
a2enconf phpmyadmin > /dev/null 2>&1

echo -e "\n--- Add environment variables to Apache ---\n"
#Put DNS info below
cat > /etc/apache2/sites-enabled/000-default.conf <<EOF
<VirtualHost *:80>
    ServerName irl.sat.iit.edu
    Redirect / https://irl.sat.iit.edu
    ServerAdmin info@geekkidconsulting.com
    DocumentRoot /var/www
    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
    SetEnv APP_ENV $APPENV
    SetEnv DB_HOST $DBHOST
    SetEnv DB_NAME $DBNAME
    SetEnv DB_USER $DBUSER
    SetEnv DB_PASS $DBPASSWD
</VirtualHost>
EOF

cat > /etc/apache2/sites-enabled/default-ssl.conf <<EOF
<VirtualHost _default_:443>
    ServerAdmin info@geekkidconsulting.com
    ServerName irl.sat.iit.edu
    ServerAlias www.irl.sat.iit.edu
    DocumentRoot /var/www/html
    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
    SSLEngine on
    SSLCertificateFile /etc/letsencrypt/live/irl.sat.iit.edu/cert.pem
    SSLCertificateKeyFile /etc/letsencrypt/live/irl.sat.iit.edu/privkey.pem
    SetEnv APP_ENV $APPENV
    SetEnv DB_HOST $DBHOST
    SetEnv DB_NAME $DBNAME
    SetEnv DB_USER $DBUSER
    SetEnv DB_PASS $DBPASSWD
</VirtualHost>
EOF

echo -e "\n--- Restarting Apache ---\n"
service apache2 restart > /dev/null 2>&1

#Don't need this yet
#echo -e "\n--- Installing Composer for PHP package management ---\n"
#curl --silent https://getcomposer.org/installer | php > /dev/null 2>&1
#mv composer.phar /usr/local/bin/composer

#echo -e "\n--- Installing NodeJS and NPM ---\n"
#apt-get -y install nodejs > /dev/null 2>&1
#curl --silent https://npmjs.org/install.sh | sh > /dev/null 2>&1

#echo -e "\n--- Installing javascript components ---\n"
#npm install -g gulp bower > /dev/null 2>&1

#echo -e "\n--- Updating project components and pulling latest versions ---\n"
#cd /vagrant
#sudo -u vagrant -H sh -c "composer install" > /dev/null 2>&1
#sudo -u vagrant -H sh -c "npm install" > /dev/null 2>&1
#sudo -u vagrant -H sh -c "bower install -s" > /dev/null 2>&1
#sudo -u vagrant -H sh -c "gulp" > /dev/null 2>&1

echo -e "\n--- Creating a symlink for future phpunit use ---\n"
ln -fs /vagrant/vendor/bin/phpunit /usr/local/bin/phpunit

echo -e "\n--- Restoring database from server. ---\n"
mysql -uroot -p$DBPASSWD -e "USE $DBNAME"

#pull backup down
mysql -u root -p$DBPASSWD $DBNAME < /vagrant/backup.sql

echo -e "\n--- Getting the latest files from team-3-irl ---\n"
git clone https://github.com/ITMT-430/team-3-irl.git /var/www/html
cd /var/www
echo "|1|9OsmSEuZ5EMLdubXJqvGQWKZy7U=|jPTfKv77HnP0Y43rUWVYFEHTYYg= ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==
|1|4kcqAWcBo5grhb07eErD5NS2jd0=|WQmwnrFYtZtb7St9xOaVwkxSyjM= ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==
">>/root/.ssh/known_hosts

ssh-keygen -t rsa -b 4096 -C "brian@geekkidconsulting.com" -f /root/.ssh/gh_rsa -N ""
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/gh_rsa
nothing=""
clear
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "+                                                                            +"
echo "+ Congratulations oh system administrator!  You have successfully advanced   +"
echo "+ to level of ""script kiddie"".  To advance to the next level, you will to      +"
echo "+ copy the output below to the deploy keys of the scripts repo.              +"
echo "+ Repo: https://github.com/ITMT-430/team3-vagrant                            +"
echo "+                                                                            +"
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo Output to copy:
cat ~/.ssh/gh_rsa.pub
read -p "Select the text to copy, the press enter to copy (in putty)" nothing
clear
read -p "Press enter to continue." nothing
git clone git@github.com:ITMT-430/team3-vagrant.git
cp -R /var/www/team3-vagrant/clone-in-here/* /var/www/
rm -rf /var/www/team3-vagrant
rm -rf /var/www/html/index.html
git clone https://github.com/ITMT-430/team-3-irl.git /var/www/html


echo -e "\n--- Add environment variables locally for artisan ---\n"
echo -e "\n--- TEST YOUR CONNECTION: 192.168.101.102 ---\n"
echo -e "\n--- Happy Coding:) ---\n"
cat >> /home/vagrant/.zshrc <<EOF

# Set envvars
export APP_ENV=$APPENV
export DB_HOST=$DBHOST
export DB_NAME=$DBNAME
export DB_USER=$DBUSER
export DB_PASS=$DBPASSWD
EOF

cd /bs
git clone https://github.com/letsencrypt/letsencrypt
cd letsencrypt
apt-get upgrade -y
./letsencrypt-auto --apache -d irl.sat.iit.edu -d www.irl.sat.iit.edu

clear
echo "+++++++++++++++++++++++++++++++++++++"
echo "+                                   +"
echo "+ Hey script kiddie: Note the pw    +"
echo "+ below!                            +"
echo "+                                   +"
echo "+++++++++++++++++++++++++++++++++++++"
echo Password:
echo $DBPASSWD
echo $DBPASSWD>>/randopw.txt
echo '<?php'>/var/www/passwords.php
echo '$dbusername="root";'>>/var/www/passwords.php
echo '$dbpassword="' $DBPASSWD '";'>>/var/www/passwords.php
echo '?>'>>/var/www/passwords.php