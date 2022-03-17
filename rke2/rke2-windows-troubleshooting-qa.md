# RKE2 Windows Troubleshooting

## High Level Notes

- For any and all RKE2 Windows Clusters, **v1.22.x or higher of RKE2 needs to be used**. This is due to a Calico 3.19.x bug in v1.21.x of RKE2 that Tigera will not backport.
- The minor version of Calico was changed midway through the RKE2 v1.22 lifecycle. 
  - rke2 v1.22.3+rke2r1 through v1.22.6+rke2r1 have Calico 3.20.x (3.20.1 for v1.22.3+rke2r1 only and then 3.20.2 until v1.22.7+rke2r1)
  - rke2 v1.22.7+rke2r1 and up have Calico 3.21.4 (or higher)

### [Calico on Windows Limitations](https://github.com/projectcalico/calico/blob/master/calico/getting-started/windows-calico/limitations.md)

### [How to start development work for RKE2 Windows](https://github.com/rosskirkpat/docs/blob/main/rke2/windows-dev.md)

### Ensure that Docker is disabled before installing RKE2 Windows on custom clusters

```powershell
stop-process dockerd
stop-service docker
set-service docker -startuptype disabled
```

----

## RKE2 Specific Debugging

----

## Calico

### StrictAffinity

#### calicoctl for 3.20.x calico (rke2 v1.22.3 -> v1.22.6)

```shell
curl -o /usr/local/bin/calicoctl -O -L  "https://github.com/projectcalico/calicoctl/releases/download/v3.20.4/calicoctl-linux-amd64" 
chmod +x /usr/local/bin/calicoctl
```

#### calicoctl for 3.21.x calico (rke2 v1.22.7+)

```shell
curl -o /usr/local/bin/calicoctl -O -L  "https://github.com/projectcalico/calico/releases/download/v3.21.4/calicoctl-linux-amd64"
chmod +x /usr/local/bin/calicoctl
```

#### calicoctl for 3.22.x (rke2 v1.23.x)

```shell
curl -o /usr/local/bin/calicoctl -O -L "https://github.com/projectcalico/calico/releases/download/v3.22.1/calicoctl-linux-amd64"
chmod +x /usr/local/bin/calicoctl
```

#### Expected output

```console
calicoctl ipam show --show-configuration
+--------------------+-------+
|      PROPERTY      | VALUE |
+--------------------+-------+
| StrictAffinity     | true  |
| AutoAllocateBlocks | true  |
| MaxBlocksPerHost   |     0 |
+--------------------+-------+
```

**Note** If StrictAffinity is set to `false`, it's possible you are using an outdated version of rke2 which had a [bug](https://github.com/rancher/rke2/issues/1617) in the implementation of Calico via [rke2-charts](https://github.com/rancher/rke2-charts/pull/132). Fixed in [v1.21.3-rc6+rke2r2](https://github.com/rancher/rke2/compare/v1.21.3-rc5+rke2r2...v1.21.3-rc6+rke2r2)

### How to fix PATH issues

### Linux

#### fix for current session

```shell
export PATH=$PATH:/var/lib/rancher/rke2/bin/
export KUBECONFIG="/etc/rancher/rke2/rke2.yaml"
export CRI_CONFIG_FILE=/var/lib/rancher/rke2/agent/etc/crictl.yaml
crictl config --set runtime-endpoint=unix:///run/k3s/containerd/containerd.sock
```

#### fix for future sessions

```shell
cat >> /etc/profile <<EOF
export KUBECONFIG=/etc/rancher/rke2/rke2.yaml
export CRI_CONFIG_FILE=/var/lib/rancher/rke2/agent/etc/crictl.yaml
export PATH="$PATH:/var/lib/rancher/rke2/bin"
crictl config --set runtime-endpoint=unix:///run/k3s/containerd/containerd.sock
alias k=kubectl
EOF
```

### Windows [ref](https://docs.rke2.io/install/quickstart/#3-configure-path)

```powershell
$env:PATH+=";c:\var\lib\rancher\rke2\bin;c:\usr\local\bin"

[Environment]::SetEnvironmentVariable(
    "Path",
    [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::Machine) + ";c:\var\lib\rancher\rke2\bin;c:\usr\local\bin",
    [EnvironmentVariableTarget]::Machine)
```

### crictl runtime endpoint issues on Windows

#### The preferred method

```powershell
$Env:CRI_CONFIG_FILE = "C:\var\lib\rancher\rke2\agent\etc\crictl.yaml"
crictl.exe ps -a
```

#### The backup method in the case of a misconfigured or missing `crictl.yaml` file

```powershell
$Env:CONTAINER_RUNTIME_ENDPOINT = "npipe:////./pipe/containerd-containerd"
crictl.exe ps -a
```

### Checking Windows RKE2 Agent logs

```powershell
# check rke2 agent event logs
# get all logs
Get-EventLog -LogName Application -Source 'rke2' | select-object -Property ReplacementStrings,TimeWritten | Format-Table -Wrap -Autosize

# get last 50
Get-EventLog -LogName Application -Source 'rke2'  -Newest 50 | select-object -Property ReplacementStrings,TimeWritten | Format-Table -Wrap -Autosize


# extract the command-line args when an exe was run
# can swap in rke2.exe, kubelet.exe, kube-proxy.exe, etc
# any exe in the C:\var\lib\rancher\rke2\bin should work for this command
Get-WmiObject Win32_Process -Filter "name = 'containerd.exe'" | Select-Object CommandLine
```

### Checking Windows rancher-wins Service logs

```powershell
# Wins
Get-WmiObject win32_service | ?{$_.Name -like '*rancher-wins*'} | Select-Object -Property * | Format-List -Wrap -Autosize

Get-WmiObject win32_service | ?{$_.Name -like '*rancher-wins*'} | select Name, DisplayName, PathName | Format-List -Wrap -Autosize

Get-EventLog -LogName Application -Newest 20 -Source 'rancher-wins' 
```

### vSphere Node Driver for RKE2 Windows Specific Debugging

```powershell
# cloudbase
Get-EventLog -LogName 'Windows PowerShell' -Message *cloudbase* 
Get-EventLog -LogName System -Message *cloudbase* 
Get-EventLog -LogName Application -Message *cloudbase* 

Get-EventLog -LogName 'Windows PowerShell' -Message *cloudbase* | Select-Object -Property * | Format-List -Wrap -Autosize
```

----

## How to check named pipes

----

```powershell
# get a list of all open named pipes
[System.IO.Directory]::GetFiles("\\.\\pipe\\")

# another alternative
get-childitem \\.\pipe\

# this returns a list of objects
(get-childitem \\.\pipe\).FullName
```

----

## General System information

----


> Helpful Articles  
[Windows container requirements](https://docs.microsoft.com/en-us/virtualization/windowscontainers/deploy-containers/system-requirements)  
[What's new for Windows containers in Windows Server 2022](https://docs.microsoft.com/en-us/virtualization/windowscontainers/about/whats-new-ws2022-containers)  


```powershell
# get system info
systeminfo

# get current build version of windows
winver

### How to Curl properly
# curl aliases to Invoke-WebRequest (iwr)
# long version: iwr -UseBasicParsing -Verbose -Uri google.com
iwr -useb -v -uri google.com

### How to use native curl.exe, which is a cross-compiled curl for windows

curl.exe -v google.com

# get the system environment variables
# most notably in here are the RKE variables and any proxy settings

Get-ChildItem env:

# windows get build ID
# returns 1809, 1903, 1909, 2004, 20h2, 2009, 2022
(Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name ReleaseId).ReleaseId

# get the cpu usage of all processes w/ descended sorting
Get-Counter '\Process(*)% Processor Time' | Select-Object -ExpandProperty countersamples| Select-Object -Property instancename, cookedvalue| ? {$_.instanceName -notmatch "^(idle|total|system)$"} | Sort-Object -Property cookedvalue -Descending| Select-Object -First 10| ft InstanceName,@{L='CPU';E={($.Cookedvalue/100/$env:NUMBER_OF_PROCESSORS).toString('P')}} -AutoSize

# get windows PATH with wrapped output
Get-ChildItem env:PATH | Format-Table -Wrap -Autosize

# start a new powershell admin session
powershell -Command "Start-Process PowerShell -Verb RunAs"
# OR
Start-Process PowerShell -Verb RunAs
```

----

## RKE2 Specific Debugging Commands

----

```powershell
# check rke2 agent event logs
Get-Eventlog -LogName Application -Source rke2 | Select-Object -Property Message | Format-List

# extract the command-line args when an exe was run
# can swap in rke2.exe, kubelet.exe, kube-proxy.exe, etc
# any exe in the C:\var\lib\rancher\rke2\bin should work for this command
Get-WmiObject Win32_Process -Filter "name = 'containerd.exe'" | Select-Object CommandLine
```

----

## Windows Defender and Windows Firewall

----

```powershell
# disable certain features of microsoft defender to increase the speed of running/setting up rke2 agent on windows

Get-MpPreference -DisableRealtimeMonitoring $true -DisableScriptScanning $true -DisableArchiveScanning $true -ExclusionPath c:\var\lib\rancher\rke2\bin,c:\usr\local\bin

# verify our defender preferences were set
Get-MpPreference
Get-MpComputerStatus

# disable Windows Firewall for all profiles
# WARNING: THIS CAN BE CATASTROPHIC IF THIS IS A PUBLICLY ACCESSIBLE NODE
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
```

----

## Windows Networking

----

> Helpful Articles  
[Introducing the Host Compute Service (HCS)](https://techcommunity.microsoft.com/t5/containers/introducing-the-host-compute-service-hcs/ba-p/382332)  
[Windows container networking](https://docs.microsoft.com/en-us/virtualization/windowscontainers/container-networking/architecture)  

```powershell
# Display the common properties for the specified network adapter

Get-NetAdapter -Name "*"
Get-NetAdapter -Name "vEthernet (nat)"
Get-NetAdapter -Name "Ethernet 3" | Format-List -Property *

# Get the network routes for a given interface index (from the get-netadapter output)

Get-NetRoute -InterfaceIndex 10


# different methods of querying network devices/IPs/Interfaces

Get-NetIPConfiguration
get-netipaddress
Get-NetIPInterface

### General Network Troubleshooting

ipconfig /allcompartments /all        

# check MTU
netsh interface ipv4 show subinterface

# Routes
Get-NetRoute
netstat -r
netsh interface ipv4 show route

# Statistics
netstat -es

# Active Connections
netstat -qb

```

----

## Microsoft HNS (Host Network System)

----

```powershell
#### You can query HNS resources using hnsdiag executable (Hyper-V Host Network Service Diagnostics Tool) or by using Powershell cmdlets.

#### I recommend using the Powershell cmdlets as they offer more functionality.

hnsdiag 

  hnsdiag <command> <object> [options ...]

   list <object>
     Lists the specified object(s).

   delete <object> <id>
     Delete the specified object.

   Objects
     All  (only valid when used with list)
     Endpoints
     Loadbalancers
     Namespaces
     Networks

   Flags
     -d
           Detailed option, when used with list, dumps the json of the object

### HNS Networks

# Get all HNS networks and details
Get-HnsNetwork

# get the nat HNS network
Get-HnsNetwork | where {$_.name -eq "nat"}

# get the vxlan0 HNS network
Get-HnsNetwork | where {$_.name -eq "vxlan0"} 

# get the cbr0 (host-gw) HNS network
Get-HnsNetwork | where {$_.name -eq "cbr0"}

# get the calico HNS network
Get-HnsNetwork | where {$_.name -eq "calico"}

### HNS Endpoints

Get-HnsEndpoint

Get-HnsEndpoint | where {$_.IPAddress -eq  "10.2.2.0"}


### HNS Policies

Get-HnsPolicyList

# check HNS policies against endpoints

$p = @(Get-HnsPolicyList | select {$_.References, Policies})
$eps = (get-hnsendpoint |  select {$_.ID})
$p1 = $p -Replace "/endpoints/"
$p = $p.Trim("/endpoints/","")
foreach ($)

# extract shared container ID and encapsulation overhead for all HNS endpoints
get-hnsendpoint | select-object -property encapoverhead, sharedcontainers

```

----

## Checking Windows Server proxy settings

----

```powershell
Get-ItemProperty -Path "Registry::HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings"
Get-ChildItem env: | findstr PROXY
Get-ChildItem env: | findstr proxy
netsh winhttp show proxy
[System.Net.WebProxy]::GetDefaultProxy()
```

----

## Adding a proxy to Windows Server

----

```powershell
netsh winhttp set proxy <proxy>:<port>
set HTTP_PROXY=<proxy>:<port>
set HTTPS_PROXY=<proxy>:<port>
set NO_PROXY=localhost,127.0.0.1,*.rancher.com
[Environment]::SetEnvironmentVariable("HTTP_PROXY", "<proxy>:<port>", [EnvironmentVariableTarget]::Machine)
[Environment]::SetEnvironmentVariable("HTTPS_PROXY", "<proxy>:<port>", [EnvironmentVariableTarget]::Machine)
[Environment]::SetEnvironmentVariable("NO_PROXY", "localhost,127.0.0.1,*.rancher.com", [EnvironmentVariableTarget]::Machine)
```

----

## Multi-platform Tests for Standalone RKE2 (useful for testing Calico Network Policies)

----

This will deploy a powershell core application on each Linux and Windows node. Once the workload is running pods will respond on port 3000/tcp.

`kubectl apply -f https://github.com/rancher/windows/blob/main/manifests/workloads/cisnodeport.yaml`

### How to test on Linux RKE2 Nodes

```powershell
# prep 
export PATH=$PATH:/var/lib/rancher/rke2/bin/
export KUBECONFIG="/etc/rancher/rke2/rke2.yaml"
export CRI_CONFIG_FILE=/var/lib/rancher/rke2/agent/etc/crictl.yaml
crictl config --set runtime-endpoint=unix:///run/k3s/containerd/containerd.sock

# exec into pstools
crictl exec -it <CONTAINER_ID> pwsh

# run inside the pod
Invoke-RestMethod <LINUX_OR_WINDOWS_POD_IP>:3000

# or use curl.exe
curl.exe -L <LINUX_OR_WINDOWS_POD_IP>:3000
```

### How to test on Windows RKE2 Nodes

```powershell
# prep
$env:PATH+=";c:\var\lib\rancher\rke2\bin;c:\usr\local\bin"
$Env:CRI_CONFIG_FILE = "C:\var\lib\rancher\rke2\agent\etc\crictl.yaml"
$Env:CONTAINER_RUNTIME_ENDPOINT = "npipe:////./pipe/containerd-containerd"

# exec into pstools
crictl exec -it <CONTAINER_ID> pwsh

# run inside the pod
Invoke-RestMethod <LINUX_OR_WINDOWS_POD_IP>:3000

# or use curl.exe
curl.exe -L <LINUX_OR_WINDOWS_POD_IP>:3000
```