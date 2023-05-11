# Bootstrap a cluster with HEAT and Kubespray
It will create a 1 bastion node with a floating ip, 1 master, 2 worker nodes cluster with:
- cri-o container engine
- cilium CNI
- openstack external cloud provider

```shell
openstack stack create -t cluster.yaml --parameter whitelisted_ip_range="10.8.0.0/16" stack name --wait
```

# Requirements
Source openrc.sh file to authenticate and retrieve token from Keystone identity service.



### Create infrastructure with HEAT template

```shell
mkdir heat
```

Create stack
```shell
openstack stack create -t cluster.yaml --parameter whitelisted_ip_range="10.8.0.0/16" heat --wait
```

Update stack
```shell
openstack stack update -t cluster.yaml --parameter whitelisted_ip_range="10.8.0.0/16" stack-name --wait
```

Delete stack
```shell
openstack stack delete heat_k8s --wait
```

Show security groups to check access:
```shell
openstack security group rule list k8s-masters
openstack security group rule list k8s-workers
```



## Same as in Main README.md
Install  Kubespray:
`git clone https://github.com/kubernetes-sigs/kubespray.git`

Install Ansible:
```shell
VENVDIR=kubespray-venv
KUBESPRAYDIR=kubespray
ANSIBLE_VERSION=2.12
python3 -m venv $VENVDIR
source $VENVDIR/bin/activate
cd $KUBESPRAYDIR
pip3 install -U -r requirements-$ANSIBLE_VERSION.txt
```

## Create an inventory for the cluster 
https://docs.infomaniak.cloud/documentation/tutorials/06.kubernetes/02.install/

https://kubespray.io/#/docs/openstack

> inventory/k8s 
runAnsible.sh to collect the necessary ips from the heat output of the cluster

```shell
bash runAnsible.sh
ansible-playbook -i inventory/k8s/hosts.yml --become --become-user=root cluster.yml
```

