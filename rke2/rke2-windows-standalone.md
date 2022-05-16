# RKE2 v1.23.6 Standalone Cluster with Windows

## Pre-Requisites

### RKE2 Server

```shell
RKE2_VERSION=v1.23.6+rke2r2

mkdir -p /etc/rancher/rke2
touch /etc/rancher/rke2/config.yaml

cat << EOF >> /etc/rancher/rke2/config.yaml
cni: "calico"
write-kubeconfig-mode: "0644"
token: thisismytokenandiwillprotectit
EOF

curl -sfL https://get.rke2.io | INSTALL_RKE2_VERSION=$RKE2_VERSION sh - 

systemctl enable rke2-server.service && systemctl start rke2-server.service

sleep 15; cat /var/lib/rancher/rke2/server/node-token

export PATH=$PATH:/var/lib/rancher/rke2/bin/
export KUBECONFIG="/etc/rancher/rke2/rke2.yaml"
crictl config --set runtime-endpoint=unix:///run/k3s/containerd/containerd.sock

# calicoctl
curl -o /usr/local/bin/calicoctl -O -L  "https://github.com/projectcalico/calicoctl/releases/download/v3.22.1/calicoctl" 
chmod +x /usr/local/bin/calicoctl
```

### RKE2 Agent

```shell
RKE2_VERSION=v1.23.6+rke2r2

curl -sfL https://get.rke2.io | INSTALL_RKE2_VERSION=$RKE2_VERSION INSTALL_RKE2_TYPE="agent" sh - 

systemctl enable rke2-agent.service 

mkdir -p /etc/rancher/rke2
touch /etc/rancher/rke2/config.yaml

cat << EOF >> /etc/rancher/rke2/config.yaml
token: <TOKEN_FROM_SERVER>
server: https://<RKE2_SERVER>:9345
EOF

export PATH=$PATH:/var/lib/rancher/rke2/bin/
crictl config --set runtime-endpoint=unix:///run/k3s/containerd/containerd.sock

systemctl start rke2-server.service
```

## RKE2 Windows Worker

```powershell
# enter admin powershell session
Powershell -Command "Start-Process PowerShell -Verb RunAs"
$ProgressPreference = 'SilentlyContinue'
Enable-WindowsOptionalFeature -Online -FeatureName Containers –All

# Install the OpenSSH Server
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0

# Start the sshd service
Start-Service sshd

# OPTIONAL but recommended:
Set-Service -Name sshd -StartupType 'Automatic'

$RKE2_VERSION="v1.23.6+rke2r2"

Invoke-WebRequest -URI https://raw.githubusercontent.com/rancher/rke2/master/install.ps1 -Outfile install.ps1

New-Item -Type Directory c:/etc/rancher/rke2 -Force
Set-Content -Path c:/etc/rancher/rke2/config.yaml -Value @"
server: https://<RKE2_SERVER>:9345
token: <TOKEN_FROM_SERVER>
"@

$env:PATH+=";c:\var\lib\rancher\rke2\bin;c:\usr\local\bin"
[Environment]::SetEnvironmentVariable(
    "Path",
    [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::Machine) + ";c:\var\lib\rancher\rke2\bin;c:\usr\local\bin",
    [EnvironmentVariableTarget]::Machine)

./install.ps1 -Version $RKE2_VERSION

rke2.exe agent service --add
```
