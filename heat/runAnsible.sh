#!/bin/bash
K8S_INVENTORY="../inventory/k8s/inventory.ini"
KUBESPRAY_DIR="kubespray"
HEAT_DIR="heat"

#cd $HEAT_DIR
# create heat stack and wait until it is completed
#openstack stack create -t cluster.yaml --parameter whitelisted_ip_range="10.8.0.0/16" heat_k8s --wait

# Get the IP address of the second network interface of the bastion server
bastion_ip=($(openstack server list -cName -cNetworks --sort-column Name -f value | awk '/bastion/ {print $4}' | tr -d "[],'" | sed 's/}//g'))

# Get the IP addresses of the k8s-master-0, k8s-worker-0, and k8s-worker-1 servers
k8s_master_0_ip=$(openstack server list -cName -cNetworks --sort-column Name -f value | awk '/k8s-master-0/ {print $3}' | tr -d "[],'" | sed 's/}//g')

k8s_worker_0_ip=$(openstack server list -cName -cNetworks --sort-column Name -f value | awk '/k8s-worker-0/ {print $3}' | tr -d "[],'" | sed 's/}//g')

k8s_worker_1_ip=$(openstack server list -cName -cNetworks --sort-column Name -f value | awk '/k8s-worker-1/ {print $3}' | tr -d "[],'" | sed 's/}//g')

# Get k8s-api load balancer VIP address
k8s_api_vip=$(openstack loadbalancer show -c vip_address k8s-api -f value)


# Save the IP addresses to the vars.yml file
cat << EOF > inventory/k8s/group_vars/vars.yml
---
bastion_ip: $bastion_ip
k8s_master_0_ip: $k8s_master_0_ip
k8s_worker_0_ip: $k8s_worker_0_ip
k8s_worker_1_ip: $k8s_worker_1_ip
k8s_api_vip: $k8s_api_vip
EOF


# Run Ansible playbook
cd "$KUBESPRAY_DIR"
ansible-playbook -i "$K8S_INVENTORY" --become --become-user=root cluster.yml
#ansible-playbook -i inventory/k8s/inventory.ini cluster.yml -b -v \--private-key=~/.ssh/private_key

