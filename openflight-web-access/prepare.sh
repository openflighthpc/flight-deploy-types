#!/bin/bash

if ! command -v ansible &> /dev/null
then
  dnf install -y ansible
fi

if ! command -v git &> /dev/null
then
  dnf install -y git
fi

# Ensure OpenFlight collection is present
ansible-galaxy collection install git+https://github.com/openflighthpc/openflight-ansible-collection.git#/openflight/
