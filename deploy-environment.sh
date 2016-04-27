#!/bin/bash

# Usage: Run on vagrant machine or another Debian box as root (not sudo - actually switch to root):
# bash <(curl -s https://raw.githubusercontent.com/ITMT-430/Team-3-Install-Scripts/master/deploy-environment.sh)

function mainmenu {
  source /euca2ools/creds/eucarc
  clear
  euca-version
  echo ""
  echo '****************************************'
  echo '*                                      *'
  echo '*             Main Menu                *'
  echo '*  What would you like to install/do?  *'
  echo '*                                      *'
  echo '****************************************'
  OPTIONS="Jenkins Production Full-Environment Quit"
  select opt in $OPTIONS; do
    if [ "$opt" = "Jenkins" ]; then
      jankie
    elif [ "$opt" = "Production" ]; then
      production
    elif [ "$opt" = "Full-Environment" ]; then
      everything
    elif [ "$opt" = "Quit" ]; then
      exit
    fi
  done
}



function jankie {
  output="$(euca-run-instances emi-c87b2863 -n 1 -k team3-new -g 'Team 3 Jenkins' -t cc1.4xlarge)"
  echo ""
  echo '****************************************'
  echo '*                                      *'
  echo '*      Sleeping for 20 seconds.        *'
  echo '*       Please freaking wait.          *'
  echo '*                                      *'
  echo '****************************************'
  sleep 20
  echo ""
  instance="$(echo "${output}" | grep -o 'i-.\{0,8\}' | head -1)"
  ipad="$(euca-describe-instances | grep ${instance} | grep -o '64\.131\.111\..\{0,3\}' | tr -s [:space:])"
  read -p "Please open a new window and ssh into ${ipad} and verify the connection works." nothing
  if test -f "~/.ssh/team3-key";
  then
    eval "$(ssh-agent)"
    ssh-add ~/.ssh/team3-key
  fi
  confirm="n"
  while [ ! ${confirm} = "Y" ]; do
    read -p "Are you ready to continue the script? (Y/n)" confirm
  done
  ssh root@${ipad} 'bash <(curl -s https://raw.githubusercontent.com/ITMT-430/Team-3-Install-Scripts/master/Jenkins/deployment.sh)'
  cont="True"
  read -p "Did the script complete successfully? (Y/n)" confirm
  if [ ${confirm} = "Y" ];
  then
    euca-associate-address -i ${instance} -a 64.131.111.60
    read -p "Jenkins should be up and running."
  else
    read -p "Are you sure? (Y/n)" confirm
    if [ ! ${confirm} = "Y" ];
    then
      euca-terminate-instances ${instance}
      echo Euca instance terminated due to script error.
      echo Please attempt running again, if it still fails,
      echo please troubleshoot the script.
      exit
    fi
  fi 
}

function production {
  echo "Production isn't ready yet."
  mainmenu
}

function everything {
  echo "Function ""everything"" isn't ready yet."
  mainmenu
}

if [ $USER = "root" ]; then
  if test -f "/bs/eucainstall";
  then
    echo Euca setup completed.  Moving on.
  else
    apt-get update
    apt-get install -y git
    apt-get install -y python-setuptools python-dev libxslt1-dev libxml2 libxml2-dev zlib1g-dev
    apt-get remove python-requests
    git clone https://github.com/jhajek/euca2ools.git /euca2ools
    cd /euca2ools
    git checkout origin/maint-3.1
    python setup.py install
    read -p "Verify there are no errors up to this point, then press any key to continue." nothing
    chmod 777 /euca2ools
    clear
    read -p "Copy your credential file to /euca2ools/creds.zip, then press any key to continue." nothing
    unzip -d creds creds.zip
    echo "source /euca2ools/creds/eucarc">>~/.bashrc
    echo "source /euca2ools/creds/eucarc">>~/.zshrc
    mkdir /bs
    touch /bs/eucainstall
  fi
  mainmenu
else
  clear
  echo "Hey you!  Ya... you!  You're an idiot!"
  echo Read the freaking documentation!
  echo "You're supposed to run this as root!!!"
  read -p "Go learn how to computer." nothing
fi