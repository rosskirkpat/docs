RKE1 to RKE2 Windows Migration Guidance

- [1. Background](#1-background)
  - [1.1. Scheduling](#11-scheduling)
  - [1.2. Supported Versions of Windows Server](#12-supported-versions-of-windows-server)
    - [1.2.1. RKE1 Windows Supported Windows Server Versions](#121-rke1-windows-supported-windows-server-versions)
      - [1.2.1.1. LTSC](#1211-ltsc)
      - [1.2.1.2. SAC](#1212-sac)
    - [1.2.2. RKE2 Windows Supports LTSC Versions of Windows Server Only](#122-rke2-windows-supports-ltsc-versions-of-windows-server-only)
      - [1.2.2.1. LTSC](#1221-ltsc)
  - [1.3. Kubernetes Version Support](#13-kubernetes-version-support)
    - [1.3.1. Rancher Manager 2.5 vs. Rancher Manager 2.6 Support Matrix for Windows Clusters](#131-rancher-manager-25-vs-rancher-manager-26-support-matrix-for-windows-clusters)
    - [1.3.2. Rancher Manager 2.5 vs Rancher Manager 2.6 Supported Kubernetes Versions for Provisioning RKE1 and RKE2 Windows Clusters](#132-rancher-manager-25-vs-rancher-manager-26-supported-kubernetes-versions-for-provisioning-rke1-and-rke2-windows-clusters)
- [2. Guiding Migrations of Workloads to RKE2 Windows](#2-guiding-migrations-of-workloads-to-rke2-windows)
  - [2.1. Steps for migrating RKE1 Windows Workloads](#21-steps-for-migrating-rke1-windows-workloads)
    - [2.1.1. In-Place Upgrade of Rancher Manager 2.5](#211-in-place-upgrade-of-rancher-manager-25)
    - [2.1.2. [Requires v2.6.5+] Migrating Windows Workloads to a new Rancher Manager environment](#212-requires-v265-migrating-windows-workloads-to-a-new-rancher-manager-environment)
      - [2.1.2.1. Use matching Kubernetes patch versions for RKE and RKE2](#2121-use-matching-kubernetes-patch-versions-for-rke-and-rke2)
      - [2.1.2.2. Use a Newer Kubernetes Patch Version for RKE2](#2122-use-a-newer-kubernetes-patch-version-for-rke2)


# 1. Background
## 1.1. Scheduling

RKE1 Windows Workload scheduling is based on taints and tolerations

RKE2 Windows Workload scheduling is based on node selectors


## 1.2. Supported Versions of Windows Server

### 1.2.1. RKE1 Windows Supported Windows Server Versions

#### 1.2.1.1. LTSC

- Windows Server 2019 LTSC :heavy_check_mark: Will reach Mainstream EOL on Jan 9, 2024 and Extended EOL on Jan 9, 2029

#### 1.2.1.2. SAC

- Windows Server 20H2 SAC :heavy_exclamation_mark: Will reach EOL on Aug 9, 2022
- Windows Server 2004 SAC :x: <mark>EOL Reached on Dec 14, 2021</mark>
- Windows Server 1909 SAC :x: <mark>EOL Reached on May 11, 2021</mark>
- Windows Server 1903 SAC :x: <mark>EOL Reached on Dec 8, 2020</mark>
- Windows Server 1809 SAC :x: <mark>EOL Reached on Nov 10, 2020</mark> 

### 1.2.2. RKE2 Windows Supports LTSC Versions of Windows Server Only

#### 1.2.2.1. LTSC

- Windows Server 2019 LTSC :heavy_check_mark: Will reach Mainstream EOL on Jan 9, 2024 and Extended EOL on Jan 9, 2029
- Windows Server 2022 LTSC :heavy_check_mark: Will reach Mainstream EOL on Oct 13, 2026 and Extended EOL on Oct 13, 2031


**References**

[Windows Server SAC Lifecycle](https://docs.microsoft.com/en-us/lifecycle/products/windows-server)

[Windows Server 2022 LTSC Lifecycle](https://docs.microsoft.com/en-us/lifecycle/products/windows-server-2022)

[Windows Server 2019 LTSC Lifecycle](https://docs.microsoft.com/en-us/lifecycle/products/windows-server-2019)


## 1.3. Kubernetes Version Support

**NB.**  All versions listed below are SLA Supported per the [Rancher Manager v2.6.5 Support Matrix](https://www.suse.com/suse-rancher/support-matrix/all-supported-versions/rancher-v2-6-5/). Any version not listed should be assumed as being EOL and not supported under SLA by SUSE

### 1.3.1. Rancher Manager 2.5 vs. Rancher Manager 2.6 Support Matrix for Windows Clusters

RKE1 vs RKE2 Windows Cluster Supported Kubernetes Versions

| Kubernetes Versions 	| RKE1 	| RKE2 	|
|---------------------	|:----:	|:----:	|
| 1.18                	|   :white_check_mark:  	|      	|
| 1.19                	|   :white_check_mark:  	|      	|
| 1.20                	|   :white_check_mark:  	|      	|
| 1.21                	|   :white_check_mark:  	|      	|
| 1.22                	|   :white_check_mark:  	|   :white_check_mark:  	|
| 1.23                	|      	|   :white_check_mark: 	|
| 1.24                	|      	|  :white_check_mark:  	|
| 1.25+               	|      	|   :white_check_mark:  	|


### 1.3.2. Rancher Manager 2.5 vs Rancher Manager 2.6 Supported Kubernetes Versions for Provisioning RKE1 and RKE2 Windows Clusters

| Rancher Manager Versions 	|    Kubernetes Versions   	| RKE1 	| RKE2 	|
|:-----------------------:	|:------------------------:	|:----:	|:----:	|
| 2.5 - RKE1 Provisioning 	|      1.18 1.19 1.20      	|   :white_check_mark:  	|      	|
| 2.6 - RKE1 Provisioning 	| 1.18 1.19 1.20 1.21 1.22 	|   :white_check_mark:  	|      	|
| 2.6 - RKE2 Provisioning 	|   1.22 1.23 1.24 1.25+   	|      	|   :white_check_mark:  	|


# 2. Guiding Migrations of Workloads to RKE2 Windows
  
Referencing the tables in [Rancher Manager 2.5 vs. Rancher Manager 2.6 Support Matrix for Windows Clusters](#rancher-25-vs-rancher-26-support-matrix-for-windows-clusters) and [Rancher Manager 2.5 vs Rancher Manager 2.6 Supported Kubernetes Versions for Provisioning RKE1 and RKE2 Windows Clusters](#rancher-25-vs-rancher-26-supported-kubernetes-versions-for-provisioning-rke1-and-rke2-windows-clusters), you will find the overlap in Kubernetes versions between RKE1 and RKE2 occurs in 1.22. This will be the base version required to migrate RKE1 Windows workloads when following the Rancher Manager recommended approach.

## 2.1. Steps for migrating RKE1 Windows Workloads 

### 2.1.1. In-Place Upgrade of Rancher Manager 2.5

- [ ] Upgrade the Rancher Manager version to v2.6.5+ 
- [ ] Upgrade the RKE1 Windows downstream cluster(s) to RKE1 v1.22 using the latest available patch version
- [ ] Provision a new RKE2 Windows downstream cluster using RKE2 v1.22 using the matching patch version that the RKE1 Windows cluster is at
- [ ] Begin the migration of the Windows workloads from RKE1 to RKE2 clusters
- [ ] Perform validation tests to ensure that there has been no functionality loss or change when migrating your application from RKE1 to RKE2
- [ ] After successful validation tests have occurred, you can opt to upgrade your RKE2 1.22.x cluster to a new minor version such as 1.23 or 1.24.


### 2.1.2. [Requires v2.6.5+] Migrating Windows Workloads to a new Rancher Manager environment

#### 2.1.2.1. Use matching Kubernetes patch versions for RKE and RKE2

- [ ] Provision a new RKE2 Windows downstream cluster using RKE2 v1.22 using the matching patch version that the RKE1 Windows cluster is at
- [ ] Begin the migration of the Windows workloads from RKE1 to RKE2 clusters
- [ ] Perform validation tests to ensure that there has been no functionality loss or change when migrating your application from RKE1 to RKE2
- [ ] After successful validation tests have occurred, you can opt to upgrade your RKE2 1.22.x cluster to a new minor version such as 1.23 or 1.24.


#### 2.1.2.2. Use a Newer Kubernetes Patch Version for RKE2

- [ ] Provision a new RKE2 Windows downstream cluster using RKE2 v1.23 or v1.24
- [ ] Begin the migration of the Windows workloads from RKE1 to RKE2 clusters
- [ ] Perform validation tests to ensure that there has been no functionality loss or change when migrating your application from RKE1 to RKE2



