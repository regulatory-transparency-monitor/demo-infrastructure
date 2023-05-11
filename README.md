# Demo-infrastructure
This repository holds the playbooks, scripts and templates for creating the infrastructure needed for the RTM.  

# Setting up the infrastructure on OpenStack 
In general, there are multiple ways how to bootstrap a Kubernetes cluster on OpenStack. The main difference lies between using a managed deployment option of self-deployment.
1. Use an orchestration management service 
    1.  [Magnum](/magnum/README.md) 
    2.  other options not explored are Rancher, Gardner
2.  Bootstrap with Kubespray
    1.  [HEAT + Ansible ](heat/README.md)
    2.  [Terraform + Ansible](terraform/README.md)

Each setup creates different API requests and flows, therefore it's necessary to investigate more than just one solution to further provide an understanding of which sources and likewise flows are relevant to the prototype. 

The resources of this repository provide at least three different approaches to Cluster deployments on OpenStack. Some requirements are necessary for each solution.
First, we need to install several tools required, create a ssh keypair and source the openrc.sh file to connect to the cloud. 

[OpenStack client documentation]( https://wiki.openstack.org/wiki/OpenStackClients)

[Access project via cli](https://kb.citynetwork.eu/kb/how-to-articles/control-panel/access-a-project-via-cli)

[Access project via command line](https://docs.openstack.org/python-openstackclient/latest/cli/command-list.html)

[Cheat Sheet](https://docs.infomaniak.cloud/cheatsheet/) 

From Infomaniak Openstack Public Cloud [300 € free credits to be used within 3 months](https://www.infomaniak.com/en/hosting/public-cloud/prices)


1. Create an API user
2. Download the user RC-file
3. Source RC-file 
`$ source <USER>--<REGION>--<PROJECT>--rc`

## Generate SSH key pair
```shell
# Generate key
ssh-keygen -t ed25519 -N '' -f ~/.ssh/id_rsa.kubespray
# Launch an SSH Agent for the current shell
eval $(ssh-agent -s)
# Add generated key
ssh-add ~/.ssh/id_rsa.kubespray
```