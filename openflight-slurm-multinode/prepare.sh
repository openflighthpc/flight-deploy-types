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

#
# Monitoring dependencies
#

# Grafana
wget -q -O /tmp/gpg.key https://rpm.grafana.com/gpg.key
rpm --import /tmp/gpg.key

cat << 'EOF' > /etc/yum.repos.d/grafana.repo
[grafana]
name=grafana
baseurl=https://rpm.grafana.com
repo_gpgcheck=1
enabled=1
gpgcheck=1
gpgkey=https://rpm.grafana.com/gpg.key
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
exclude=*beta*
EOF

dnf install -y grafana

# Prometheus

mkdir -p /opt/flight/opt/prometheus
wget -O /tmp/prometheus.tar.gz https://github.com/prometheus/prometheus/releases/download/v2.51.1/prometheus-2.51.1.linux-amd64.tar.gz
cd /opt/flight/opt/prometheus
tar xf /tmp/prometheus.tar.gz --strip-components=1

cat << 'EOF' > /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus Server
Documentation=https://prometheus.io/docs/introduction/overview/
After=network-online.target

[Service]
Restart=on-failure
ExecStart=/opt/flight/opt/prometheus/prometheus \
  --config.file=/opt/flight/opt/prometheus/prometheus.yml \
  --storage.tsdb.path=/opt/flight/opt/prometheus/data \
  --storage.tsdb.retention.time=30d

[Install]
WantedBy=multi-user.target
EOF

# Node Exporter
mkdir -p /opt/flight/opt/node_exporter
wget -O /tmp/node_exporter.tar.gz https://github.com/prometheus/node_exporter/releases/download/v1.7.0/node_exporter-1.7.0.linux-amd64.tar.gz
cd /opt/flight/opt/node_exporter
tar xf /tmp/node_exporter.tar.gz --strip-components=1

cat << 'EOF' > /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
After=network.target

[Service]
Type=simple
ExecStart=/opt/flight/opt/node_exporter/node_exporter --collector.systemd --collector.processes

[Install]
WantedBy=multi-user.target
EOF

# Tidy
rm -f /tmp/gpg.key /tmp/prometheus.tar.gz /tmp/node_exporter.tar.gz /etc/yum.repos.d/grafana.repo

