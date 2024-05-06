#!/bin/bash

if ! command -v ansible &> /dev/null
then
  dnf install -y ansible
fi

if ! command -v git &> /dev/null
then
  dnf install -y git
fi

dnf install -y munge munge-libs perl-Switch numactl flight-slurm flight-slurm-devel flight-slurm-perlapi flight-slurm-torque flight-slurm-slurmd flight-slurm-example-configs flight-slurm-libpmi flight-slurm-slurmctld

dnf install -y nfs-utils

# IPA
CENTOS_VER=$(rpm --eval '%{centos_ver}')
if [[ $CENTOS_VER == 9 ]] ; then
    dnf -y install freeipa-server freeipa-server-dns freeipa-client
else
    dnf module reset -y idm
    dnf module enable -y idm:DL1
    dnf module install -y idm:DL1/dns
fi

# ensure v6.6.0 or above installed for append option in ipa_hostgroup
ansible-galaxy collection install 'community.general:>6.6.0' --upgrade

# Ensure jmespath installed for use of json_query, using python ansible is looking at
PYTHON="$(ansible --version |grep 'python version' |sed 's/.*(//g;s/)//g')"
$PYTHON -m pip install jmespath

# Ensure OpenFlight collection is present
ansible-galaxy collection install git+https://github.com/openflighthpc/openflight-ansible-collection.git#/openflight/

