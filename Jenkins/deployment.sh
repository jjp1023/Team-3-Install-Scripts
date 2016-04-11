#!/bin/bash


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
#---------------------------------------End Base System Install----------------------------------------------

#------------------------------------------Install Jenkins---------------------------------------------------
wget -q -O - https://jenkins-ci.org/debian/jenkins-ci.org.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins-ci.org/debian binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt-get update
sudo apt-get install -y jenkins
#----------------------------------------Finish Install Jenkins----------------------------------------------

#------------------------------------------Configure System--------------------------------------------------
echo alias confj="cd /var/lib/jenkins">>~/.zshrc
echo clear>>~/.zshrc
echo echo "You Are Doomed OS (C) 2016 - Brian Semrau">>~/.zshrc
ssh-keygen -t rsa -b 4096 -C "brian@geekkidconsulting.com" -f /root/.ssh/gh_rsa -N ""
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/gh_rsa
clear
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "+                                                                            +"
echo "+ Congratulations oh system administrator!  You have successfully advanced   +"
echo "+ to level of ""script kiddie"".  To advance to the next level, you will to     +"
echo "+ copy the output below to the deploy keys of the scripts repo.              +"
echo "+ Repo: https://github.com/ITMT-430/Team-3-Install-Scripts                   +"
echo "+                                                                            +"
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo Output to copy:
cat ~/.ssh/gh_rsa.pub
read -p "Select the text to copy, the press enter to copy (in putty)" nothing
clear
read -p "Press enter to continue."
#--------------------------------------Finish Configure System-----------------------------------------------

#----------------------------------------Configure Jenkins---------------------------------------------------
service jenkins stop
cd /var/lib/jenkins
rm -rf /var/lib/jenkins/*
git clone git@github.com:ITMT-430/team-3-jenkins-config.git
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