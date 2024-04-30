#!/bin/bash

if ! command -v ansible &> /dev/null
then
  dnf install -y ansible
fi

if ! command -v git &> /dev/null
then
  dnf install -y git
fi

# NFS utils
dnf install -y nfs-utils

# Docker Repo
dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo

# Docker Packages
dnf install -y docker-ce containerd

# Kubenetes Repo
cat << EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.30/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.30/rpm/repodata/repomd.xml.key
exclude=kubelet kubeadm kubectl cri-tools kubernetes-cni
EOF

# Kubernetes Packages
dnf install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

# Kubernetes Images
containerd config default > /etc/containerd/config.toml
systemctl start containerd
kubeadm config images pull
systemctl stop containerd

# Tidy Up
rm -f /etc/yum.repos.d/kubernetes.repo /etc/yum.repos.d/docker-ce.repo

# Ensure jmespath installed for use of json_query, using python ansible is looking at
PYTHON="$(ansible --version |grep 'python version' |sed 's/.*(//g;s/)//g')"
$PYTHON -m pip install jmespath

# Ensure OpenFlight collection is present
ansible-galaxy collection install git+https://github.com/openflighthpc/openflight-ansible-collection.git#/openflight/
