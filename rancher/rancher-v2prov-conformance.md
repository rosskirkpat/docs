# Rancher conformance for CAPI

## Custom

Per Node:
1 CAPI Machine  
1 RKE Custom Machine - custommachines.rke.cattle.io

## capi custom rke2 cluster

for every etcd node:

for every cp node:

for every worker node:

## capi custom k3s cluster

for every etcd node:

for every cp node:

for every worker node:

## vSphere

In the local cluster for each v2prov rke2 node driver nodes (including harvester, vsphere):

3 serviceaccounts  
8 secrets  
3 rolebindings  
2 roles  
1 rkebootstrap (rke.cattle.io/v1)  
1 vmwarevspheremachine (rke-machine.cattle.io/v1)  
1 machine (cluster.x-k8s.io/v1beta1)  

A v2prov vSphere rke2 cluster consists of

Per Node:

1 CAPI Machine - machines.cluster.x-k8s.io  
1 Rancher v3 Node - nodes.management.cattle.io  
1 vmwarevspheremachine - vmwarevspheremachines.rke-machine-config.cattle.io  
1 vmwarevsphereconfig - vmwarevsphereconfigs.rke-machine-config.cattle.io  
1 RKEBootstrap  
3 service accounts  
3 rolebindings  
2 roles  

8 secrets  
1 bootstrap secret - rke.cattle.io/bootstrap  
1 machine state secret - rke.cattle.io/machine-state  
1 machine plan secret - rke.cattle.io/machine-plan  

Per Pool:

1 RKEControlPlane  
1 RKEBootstrapTemplate  
1 MachineDeployment - machinedeployments.cluster.x-k8s.io  
1 MachineSet - machinesets.cluster.x-k8s.io  

Per Cluster:

1 CAPI cluster - clusters.cluster.x-k8s.io  
1 Rancher v3 cluster - clusters.management.cattle.io  
1 Rancher provisioning v1 cluster - clusters.provisioning.cattle.io  

## capi vsphere rke2 cluster

for every etcd node:

for every cp node:

for every worker node:

## capi vsphere k3s cluster

for every etcd node:

for every cp node:

for every worker node:

## EC2

## capi ec2 rke2 cluster

for every etcd node:

for every cp node:

for every worker node:

## capi ec2 k3s cluster

for every etcd node:

for every cp node:

for every worker node:

## Harvester

## harvester CRDs required for rke2

15 harvester CRDs  
15 longhorn CRDs  
9 kubevirt CRDs  

14 Calico CRDs  

6 cluster-api CRDs  
5 rke.cattle.io (v2prov) CRDs  
