#!/bin/bash -p


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
apt-get install -y build-essential
apt-get install -y php5
apt-get install -y php5-dev
apt-get install -y php-pear
pear channel-discover pear.phing.info
pear install phing/phing
pear install VersionControl_Git-alpha
#---------------------------------------End Base System Install----------------------------------------------

#------------------------------------------Install Jenkins---------------------------------------------------
wget -q -O - https://jenkins-ci.org/debian/jenkins-ci.org.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins-ci.org/debian binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt-get update
sudo apt-get install -y jenkins
#----------------------------------------Finish Install Jenkins----------------------------------------------

#------------------------------------------Configure System--------------------------------------------------
echo alias confj="cd /var/lib/jenkins">>~/.zshrc
echo echo "You Are Doomed OS (C) 2016 - Brian Semrau">>~/.zshrc
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
echo "+ Repo: https://github.com/ITMT-430/team-3-jenkins-config                    +"
echo "+                                                                            +"
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo Output to copy:
cat ~/.ssh/gh_rsa.pub
read -p "Select the text to copy, the press enter to copy (in putty)" nothing
clear
read -p "Press enter to continue." nothing
echo "cd /var/lib/jenkins">>/etc/cron.hourly/backup_checker.sh
echo "git status | grep 'nothing to commit' &> /dev/null">>/etc/cron.hourly/backup_checker.sh
echo "if git status | grep -q 'nothing to commit'; then">>/etc/cron.hourly/backup_checker.sh
echo "    exit">>/etc/cron.hourly/backup_checker.sh
echo "else">>/etc/cron.hourly/backup_checker.sh
echo "    git add --all">>/etc/cron.hourly/backup_checker.sh
echo "    git commit -m 'Automatic backup'">>/etc/cron.hourly/backup_checker.sh
echo "    git push origin master">>/etc/cron.hourly/backup_checker.sh
echo "    exit">>/etc/cron.hourly/backup_checker.sh
echo "fi">>/etc/cron.hourly/backup_checker.sh
chmod +x /etc/cron.hourly/backup_checker.sh
echo "15 * * * * sh -c /etc/cron.hourly/backup_checker.sh">>/etc/crontab
#--------------------------------------Finish Configure System-----------------------------------------------
#----------------------------------------Configure Jenkins---------------------------------------------------
service jenkins stop
cd /var/lib/
rm -rf /var/lib/jenkins
mkdir /var/lib/jenkins
echo "|1|9OsmSEuZ5EMLdubXJqvGQWKZy7U=|jPTfKv77HnP0Y43rUWVYFEHTYYg= ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==
|1|4kcqAWcBo5grhb07eErD5NS2jd0=|WQmwnrFYtZtb7St9xOaVwkxSyjM= ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==
">>/root/.ssh/known_hosts
git clone git@github.com:ITMT-430/team-3-jenkins-config.git /var/lib/jenkins
#Jenkins always crashes without 777 permissions.  Tried a ton of things, can't figure out a way around it.  :/
#Reset permissions after clone just in case.
chmod 777 /var/lib/jenkins
service jenkins start
#---------------------------------------End Configure Jenkins------------------------------------------------
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "+                                                                            +"
echo "+ Congratulations oh system administrator!  You have successfully completed  +"
echo "+ your script kiddie quest and installed and configured Jenkins.  Good bye!  +"
echo "+ sudo rm -rf /                                                              +"
echo "+                                                                            +"
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
chsh -s /bin/zsh