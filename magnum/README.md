# Create Cluster using Magnum 
Use Magnum to create Kubernetes clusters on OpenStack. The configuration is based on a Cluster Template which is provided as "ready-to-use" configuration.


## Requirements:
Upload an SSH key and source the openrc.sh file for cloud access.

`pip3 install python-magnumclient`

## Usage
list all available templates in the region -> $CLUSTER_TMPL:
```shell
$ openstack coe cluster template list
```

check cluster creation process:
```shell
$ openstack coe cluster list -c status
```

show created cluster:
```shell
$ openstack coe cluster show $CLUSTER_NAME
```

[Managing Kubernetes cluster](https://docs.cleura.cloud/howto/openstack/magnum/kubectl/)


## Work with the cluster
List cluster and show even more details:

```shell
$ openstack coe cluster list
$ openstack coe cluster show $CLUSTER_NAME
```


Extract config: 
```shell
$ openstack coe cluster config --dir=${PWD} $CLUSTER_NAME
$ export KUBECONFIG=${PWD}/config
```

Dynamic volume provision:
> storageclass.yaml
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: csi-sc-cinderplugin
  annotations:
    "storageclass.kubernetes.io/is-default-class": "true"
provisioner: cinder.csi.openstack.org
```

## Option 2 use Gardener
[Gardener - Cluster as a service](https://docs.cleura.cloud/howto/kubernetes/gardener/create-shoot-cluster/)