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
dnf module reset -y idm
dnf module enable -y idm:DL1
dnf module install -y idm:DL1/dns

ansible-galaxy collection install freeipa.ansible_freeipa

if [ ! -d openflight-slurm-multinode/.git ]
then
  git clone https://github.com/openflighthpc/openflight-slurm-multinode
fi
cd openflight-slurm-multinode
git pull
