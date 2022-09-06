#!/bin/bash

if ! command -v ansible &> /dev/null
then
  yum install -y ansible
fi

# check if git repo exists
current_dir=$PWD
cd /home/openflight
git clone https://github.com/openflighthpc/openflight-ansible-playbook || (cd openflight-ansible-playbook ; git pull)
cd $current_dir

