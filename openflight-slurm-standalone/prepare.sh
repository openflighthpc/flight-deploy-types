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

if [ ! -d openflight-slurm-standalone/.git ]
then
  git clone https://github.com/openflighthpc/openflight-slurm-standalone
fi
cd openflight-slurm-standalone
git pull
