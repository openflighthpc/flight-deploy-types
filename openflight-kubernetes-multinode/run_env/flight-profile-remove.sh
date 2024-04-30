#!/bin/bash

ansible-playbook -i $INVFILE --extra-vars="cluster_name=$CLUSTERNAME default_username=$DEFAULT_USERNAME default_user_password=$DEFAULT_PASSWORD access_host=$ACCESS_HOST compute_ip_range=$COMPUTE_IP_RANGE pod_ip_range=$POD_IP_RANGE hunter_hosts=$HUNTER_HOSTS" --extra-vars="{"remove_node": [$NODE]}" --tags remove $RUN_ENV/remove.yml
