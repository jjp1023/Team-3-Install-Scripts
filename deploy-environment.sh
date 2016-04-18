#!/bin/bash

# Usage: Run on vagrant machine or another Debian box as root (not sudo - actually switch to root):
# bash <(curl -s https://raw.githubusercontent.com/ITMT-430/Team-3-Install-Scripts/master/deploy-environment.sh)
apt-get update
apt-get install -y git
apt-get install -y python-setuptools python-dev libxslt1-dev libxml2 libxml2-dev zlib1g-dev
apt-get remove python-requests
git clone https://github.com/jhajek/euca2ools.git /euca2ools
cd /euca2ools
git checkout origin/maint-3.1
python setup.py install
read -p "Verify there are no errors up to this point, then press any key to continue." nothing
clear
read -p "Copy your credential file to /euca2ools/creds.zip, then press any key to continue." nothing
unzip -d creds creds.zip
source /euca2ools/creds/eucarc
echo "source /euca2ools/creds/eucarc">>~/.bashrc
echo "source /euca2ools/creds/eucarc">>~/.zshrc
echo "Sometimes one of these commands doesn't work right in a script."
echo "If there was an error above, please open a new terminal and type:"
read -p "source /euca2ools/creds/eucarc" nothing
euca-version
output="$(euca-run-instances emi-c87b2863 -n 1 -k team3-new -g 'Team 3 Jenkins' -t c1.xlarge)"
instance="$(echo "${output}" | grep -o 'i-.\{0,8\}' | head -1)"
ipad="$(euca-describe-instances | grep $(echo ${instance}) | grep -o '64\.131\.111\..\{0,3\}' | tr -s [:space:])"
echo $output
echo $instance
echo $ipad
read -p "Please open a new window and ssh into ${ipad} and verify the connection works." nothing
confirm="n"
while [![${confirm}=="Y"]]; do
  read -p "Are you ready to continue the script? (Y/n)" confirm
done
ssh root@${ipad} 'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ITMT-430/Team-3-Install-Scripts/master/Jenkins/deployment.sh)"'
cont="True"
read -p "Did the script complete successfully? (Y/n)" confirm
if [ ![ ${confirm}=="Y") ] ]
then
  read -p "Are you sure? (Y/n)" confirm
  if [ ![ ${confirm}=="Y"] ]
  then
    cont="False"
    euca-terminate-instances ${instance}
    echo Euca instance terminated due to script error.
    echo Please attempt running again, if it still fails,
    echo please troubleshoot the script.
    exit
  fi
fi
if [ cont=="True" ]
then
  euca-associate-address -i ${instance} -a 64.131.111.60
  read -p "Proper address assigned.  Jenkins should be up and running."
fi
exit
