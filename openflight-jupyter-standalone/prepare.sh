#!/bin/bash

if ! command -v ansible &> /dev/null
then
  dnf install -y ansible
fi

if ! command -v git &> /dev/null
then
  dnf install -y git
fi



dnf install -y python39
# unsure if the -y option works with pip install
pip3.9 install jupyterlab 



# Passwordless SSH for Root
KEYNAME="/root/.ssh/id_flightprofile"
if [ ! -f $KEYNAME ]
then
  ssh-keygen -t rsa -N '' -f $KEYNAME
fi
if ! grep -q "$(cat $KEYNAME.pub)" /root/.ssh/authorized_keys
then
  cat $KEYNAME.pub >> /root/.ssh/authorized_keys
fi
if ! grep -q "IdentityFile $KEYNAME" /root/.ssh/config
then
  echo "Host *" >> /root/.ssh/config
  echo "  IdentityFile $KEYNAME" >> /root/.ssh/config
fi

if [ ! -d openflight-jupyter-standalone/.git ]
then
  git clone https://github.com/openflighthpc/openflight-jupyter-standalone
fi
cd openflight-jupyter-standalone
git pull
