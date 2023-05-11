# Bootstrap a cluster with terraform and Kubespray
For general reference, the following sources were used:

[Kubespray - Terraform for OpenStack](https://github.com/kubernetes-sigs/kubespray/blob/v2.20.0/contrib/terraform/openstack/README.md)

[Kubespray - Configurations for OpenStack](https://kubespray.io/#/docs/openstack)

## Generate SSH key pair
```shell
# Generate key
ssh-keygen -t ed25519 -N '' -f ~/.ssh/id_rsa.kubespray
# Launch an SSH Agent for the current shell
eval $(ssh-agent -s)
# Add generated key
ssh-add ~/.ssh/id_rsa.kubespray
```

## Requirements
- [terraform](https://www.terraform.io/)
- [kubectrl](https://kubernetes.io/docs/reference/kubectl/)

Source the openrc.sh file 
```shell
source ../PCP-JMY29J4-openrc.sh
```

Download kubespray
```shell
git clone https://github.com/kubernetes-sigs/kubespray
```

Prepare Python virtual env
```shell
VENVDIR=kubespray-venv
KUBESPRAYDIR=kubespray
ANSIBLE_VERSION=2.12
python3 -m venv $VENVDIR
source $VENVDIR/bin/activate
cd $KUBESPRAYDIR
pip3 install -U -r requirements-$ANSIBLE_VERSION.txt
```

## Create the infrastructure 

### Prepare inventory 
option 1:
```shell
$ mkdir inventory/$CLUSTER
$ cd inventory/$CLUSTER
$ terraform init -from-module=../../contrib/terraform/openstack
$ cp sample-inventory/cluster.tfvars .
$ rm -r sample-inventory/
$ cp -r ../sample/group_vars/ group_vars
$ ln -sf ../../contrib/terraform/openstack/hosts
```

option 2:
```shell
$ cp -LRp contrib/terraform/openstack/sample-inventory inventory/$CLUSTER
$ cd inventory/$CLUSTER
$ ln -s ../../contrib/terraform/openstack/hosts
> Important step: the host file should now be in the inventory/$CLUSTER linked to the one in ~/openstack/hosts

$ ln -s ../../contrib
```


## Configure Terraform cluster.tfvars 
For reference: https://github.com/kubernetes-sigs/kubespray/blob/v2.20.0/contrib/terraform/openstack/README.md#cluster-variables

It will create a 1 master 3 worker nodes cluster with:
- cri-o container engine
- cilium CNI
- openstack external cloud provider

> [cluster.tfvars](inventory/demo-k8s-cluster/cluster.tfvars) holds the varibles for terraform 

## Apply the Terraform plan
```shell
cd inventory/$CLUSTER
terraform apply -var-file=cluster.tfvars
```

## Configure the kubespray inventory
> [all/all.yml](inventory/demo-k8s-cluster/group_vars/all/all.yml)

> [all/cri-o.yml](inventory/demo-k8s-cluster/group_vars/all/cri-o.yml)

> [all/openstack.yml](inventory/demo-k8s-cluster/group_vars/all/openstack.yml)

> [k8s_cluster/k8s-cluster.yml](inventory/demo-k8s-cluster/group_vars/k8s_cluster/k8s-cluster.yml)

> [k8s_cluster/addons.yml ](inventory/demo-k8s-cluster/group_vars/k8s_cluster/addons.yml)
> for Dashboard deployment

## Terrarform commands 
Initialize Terraform: 
> run the commands from inside kubespray/inventory/$CLUSTER 

```shell
cd inventory/$CLUSTER
terraform apply -var-file=cluster.tfvars
terraform -chdir="../../contrib/terraform/openstack" init
```
Apply:  
```shell
terraform -chdir="../../contrib/terraform/openstack" apply -var-file=$PWD/cluster.tfvars
```
Destroy: 
```shell
terraform -chdir="../../contrib/terraform/openstack" destroy -var-file=$PWD/cluster.tfvars
```

##  Deploy Kubespray
`cd ../..`

### Test ssh connection 
```shell
ansible -i inventory/demo-k8s-cluster/hosts -m ping all
```
### Run playbook to install cluster

```shell
ansible-playbook --become -i inventory/$CLUSTER/hosts cluster.yml
```
## Validate 
```shell
kubectl run -ti --rm --restart=Never --overrides='{"spec": { "terminationGracePeriodSeconds" :0 } }' toolbox --image=ghcr.io/reneluria/alpinebox:1.3.2 -- bash -c 'curl --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt -H "Authorization: Bearer $(</var/run/secrets/kubernetes.io/serviceaccount/token)" https://kubernetes.default/api'
```

### To troubleshoot the playbook:
> set verbosity level --(v,vv,vvv)
> export ANSIBLE_DEBUG=1
```shell
ansible-playbook --become -i inventory/demo-k8s-cluster/hosts cluster.yml --start-at-task="kubernetes/preinstall : Check if kubernetes kubeadm compat cert dir exists"

ansible-playbook --become -i inventory/demo-k8s-cluster/hosts cluster.yml --start-at-task="Write resolved.conf" -vvv
```

## Create User and Roles
> inventory/demo-k8s-cluster/manifest

```shell
kubectl apply -f admin_account.yaml
kubectl apply -f admin_role.yaml
```

## Access the Kubernetes Dashboard
`kubectl -n kube-system create token admin-user`

Get the API server address:
`APISERVER=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')`

> Use kubeconfig file at inventory/$CLUSTER/artifacts/admin.conf

