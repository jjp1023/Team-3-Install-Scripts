#!/bin/bash

#---------------------------Base System Install - should be run on every system------------------------------
apt-get update
apt-get install -y curl
apt-get install -y git
apt-get install -y vim
apt-get install -y zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
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
sudo apt-get install jenkins
#----------------------------------------Finish Install Jenkins----------------------------------------------