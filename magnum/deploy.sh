#!/bin/bash
source ghost--fra1--ghosttown--rc
CLUSTER_NAME="k8s-cluster"
CLUSTER_TMPL="f9e1a2ea-b1ff-43e7-8d1e-6dd5861b82cf" 
KEYPAIR="k8sKey"

openstack coe cluster create \
    --cluster-template $CLUSTER_TMPL \
    --keypair $KEYPAIR \
    $CLUSTER_NAME

openstack coe cluster list -c status