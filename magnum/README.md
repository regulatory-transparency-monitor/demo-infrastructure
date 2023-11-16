# Bootstrap a Kubernetes cluster using Magnum 
Use Magnum to create Kubernetes clusters on OpenStack. The configuration is based on a Cluster Template which is provided as "ready-to-use" configuration.


## Requirements:
- upload SSH key pair to cloud project 
- source the openrc.sh file 
- install openStack sdks, you need magnum: `pip3 install python-magnumclient`

## Usage
list all available templates in the region 
```shell
openstack coe cluster template list
```

check cluster creation process:
```shell 
openstack coe cluster list -c status
```

show created cluster:
```shell
openstack coe cluster show $CLUSTER_NAME
```

[Managing Kubernetes cluster](https://docs.cleura.cloud/howto/openstack/magnum/kubectl/)


## Work with the cluster
List cluster and show even more details:

```shell
openstack coe cluster list
openstack coe cluster show $CLUSTER_NAME
```


Extract config: 
```shell
openstack coe cluster config --dir=${PWD} $CLUSTER_NAME
export KUBECONFIG=${PWD}/config
```

Dynamic volume provision: `storageclass.yaml`

Access the Kubernetes Dashboard:
```shell
kubectl proxy --port=8080 
```
Browse to acces the dashbaord: 
>http://localhost:8080/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/#/login
>
> http://localhost:8080/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/#/pod/sock-shop/front-end-64c558644d-jlk6c?namespace=sock-shop
> 
> http://127.0.0.1:8080/api/v1/namespaces/sock-shop/services/https:front-end:30001/proxy/

