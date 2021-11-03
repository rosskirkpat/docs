RKE2 Windows Troubleshooting

RKE2 Specific
------------------------

## Calico
### StrictAffinity 

# calicoctl for 3.19.x calico (k8s 1.21)
```shell

curl -o /usr/local/bin/calicoctl -O -L  "https://github.com/projectcalico/calicoctl/releases/download/v3.19.1/calicoctl" 
chmod +x /usr/local/bin/calicoctl
```

# calicoctl for 3.20.x calico (k8s 1.22)
```shell

curl -o /usr/local/bin/calicoctl -O -L  "https://github.com/projectcalico/calicoctl/releases/download/v3.20.2/calicoctl-linux-amd64" 
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

## PATH issues

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


## crictl runtime endpoint issues on Windows

### The preferred method
```powershell
$Env:CRI_CONFIG_FILE = "C:\var\lib\rancher\rke2\agent\etc\crictl.yaml"
crictl.exe ps -a
```

### The backup method in the case of a misconfigured or missing `crictl.yaml` file
```powershell
$Env:CONTAINER_RUNTIME_ENDPOINT = "npipe:////./pipe/containerd-containerd"
crictl.exe ps -a
```

How to check named pipes
------------------------

```
# get a list of all open named pipes
[System.IO.Directory]::GetFiles("\\.\\pipe\\")

# another alternative
get-childitem \\.\pipe\

# this returns a list of objects
(get-childitem \\.\pipe\).FullName


General System information
--------------------------

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

# disable certain features of microsoft defender to increase the speed of running/setting up rke2 agent on windows

Get-MpPreference -DisableRealtimeMonitoring $true -DisableScriptScanning $true -DisableArchiveScanning $true -ExclusionPath c:\var\lib\rancher\rke2\bin,c:\usr\local\bin

# verify our defender preferences were set
Get-MpPreference
Get-MpComputerStatus

# windows get build ID
# returns 1809, 1903, 1909, 2004, 20h2, 2009, 2022
(Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name ReleaseId).ReleaseId

# get the cpu usage of all processes w/ descended sorting
Get-Counter '\Process(*)% Processor Time' | Select-Object -ExpandProperty countersamples| Select-Object -Property instancename, cookedvalue| ? {$_.instanceName -notmatch "^(idle|total|system)$"} | Sort-Object -Property cookedvalue -Descending| Select-Object -First 10| ft InstanceName,@{L='CPU';E={($.Cookedvalue/100/$env:NUMBER_OF_PROCESSORS).toString('P')}} -AutoSize

# check rke2 agent event logs
Get-Eventlog -LogName Application -Source rke2 | Select-Object -Property Message | Format-List

# get windows PATH with wrapped output
Get-ChildItem env:PATH | Format-Table -Wrap -Autosize

# start a new powershell admin session
powershell -Command "Start-Process PowerShell -Verb RunAs"
# OR
Start-Process PowerShell -Verb RunAs

# extract the command-line args when an exe was run
# can swap in rke2.exe, kubelet.exe, kube-proxy.exe, etc
# any exe in the C:\var\lib\rancher\rke2\bin should work for this command
Get-WmiObject Win32_Process -Filter "name = 'containerd.exe'" | Select-Object CommandLine


Networking
--------------------------

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


# check HNS policies against endpoints

$p = @(Get-HnsPolicyList | select {$_.References, Policies})
$eps = (get-hnsendpoint |  select {$_.ID})
$p1 = $p -Replace "/endpoints/"
$p = $p.Trim("/endpoints/","")
foreach ($)


# extract shared container ID and encapsulation overhead for all HNS endpoints
get-hnsendpoint | select-object -property encapoverhead, sharedcontainers



HNS
---

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


Checking proxy settings
-----------------------

Get-ItemProperty -Path "Registry::HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings"
Get-ChildItem env: | findstr PROXY
Get-ChildItem env: | findstr proxy
netsh winhttp show proxy
[System.Net.WebProxy]::GetDefaultProxy()


Adding a proxy
--------------

netsh winhttp set proxy <proxy>:<port>
set HTTP_PROXY=<proxy>:<port>
set HTTPS_PROXY=<proxy>:<port>
set NO_PROXY=localhost,127.0.0.1,*.rancher.com
[Environment]::SetEnvironmentVariable("HTTP_PROXY", "<proxy>:<port>", [EnvironmentVariableTarget]::Machine)
[Environment]::SetEnvironmentVariable("HTTPS_PROXY", "<proxy>:<port>", [EnvironmentVariableTarget]::Machine)
[Environment]::SetEnvironmentVariable("NO_PROXY", "localhost,127.0.0.1,*.rancher.com", [EnvironmentVariableTarget]::Machine)
