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
