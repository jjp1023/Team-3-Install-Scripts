#!/bin/bash
apt-get update
apt-get install -y git
apt-get install -y python-setuptools python-dev libxslt1-dev libxml2 libxml2-dev zlib1g-dev
mkdir /euca2ools
cd /euca2ools
git clone https://github.com/jhajek/euca2ools.git
git checkout origin/maint-3.1
python setup.py install
read -p "Verify there are no errors up to this point, then press any key to continue." nothing
clear
read -p "Copy your credential file to /euca2ools/creds.zip, then press any key to continue." nothing
unzip -d creds creds.zip
source /euca2ools/creds/eucarc
source /euca2ools/creds/eucarc>>~/.bashrc
source /euca2ools/creds/eucarc>>~/.zshrc