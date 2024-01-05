#!/bin/bash

set -e

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

if [ ! -d openflight-jupyter-standalone/.git ]
then
  git clone https://github.com/openflighthpc/openflight-jupyter-standalone
fi
cd openflight-jupyter-standalone
git pull
