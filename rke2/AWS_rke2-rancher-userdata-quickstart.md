# AWS EC2 Quickstart single node RKE2 Server running Rancher


- Steps:
  - Configure new EC2 instance with at least 2cpu/8gb 
  - Include the following user-data [aws_rke2-rancher-userdata.sh](https://github.com/rosskirkpat/docs/blob/main/rke2/scripts/aws_rke2-rancher-userdata.sh)
 in the Advanced section of the ec2 instance configuration
  - Substitute in a different version of Rancher by modifying the value of `rancherImageTag` as needed
  - Update the value of `INSTALL_RKE2_VERSION` to match your required rke2 version
  - Update `cni` as needed if you require the use of a CNI other than Calico (the default in 2.6.0)
  - Rancher will be available in 1-5 minutes at `"${PUBLIC_IP}.nip.io"`, which redirects to the public IP address of your EC2 instance.

**Note** There is also a copy of the user-data below but please note it may not be up to date with the latest changes and was current as of Aug. 16th, 2021.

```shell
#!/bin/sh
# setup rke2 server and install rancher
PUBLIC_IP=$(curl ifconfig.io)

export INSTALL_RKE2_VERSION="v1.21.3-rc6+rke2r2"

curl -sfL https://get.rke2.io | sh -
mkdir -p /etc/rancher/rke2
cat > /etc/rancher/rke2/config.yaml <<EOF
write-kubeconfig-mode: "0640"
tls-san:
  - "${PUBLIC_IP}" 
  - "${PUBLIC_IP}.nip.io"
cni: "calico"
node-external-ip: "${PUBLIC_IP}"
EOF

systemctl enable rke2-server
systemctl start rke2-server

cat >> /etc/profile <<EOF
export KUBECONFIG=/etc/rancher/rke2/rke2.yaml
export CRI_CONFIG_FILE=/var/lib/rancher/rke2/agent/etc/crictl.yaml
export PATH="$PATH:/var/lib/rancher/rke2/bin"
crictl config --set runtime-endpoint=unix:///run/k3s/containerd/containerd.sock
alias k=kubectl
EOF

export KUBECONFIG=/etc/rancher/rke2/rke2.yaml
export CRI_CONFIG_FILE=/var/lib/rancher/rke2/agent/etc/crictl.yaml
export PATH="$PATH:/var/lib/rancher/rke2/bin"
crictl config --set runtime-endpoint=unix:///run/k3s/containerd/containerd.sock

mkdir -p /var/lib/rancher/rke2/server/manifests
cat >> /var/lib/rancher/rke2/server/manifests/rke2-ingress-nginx-config.yaml <<EOF
apiVersion: helm.cattle.io/v1
kind: HelmChartConfig
metadata:
  name: rke2-ingress-nginx
  namespace: kube-system
spec:
  valuesContent: |-
    controller:
      kind: DaemonSet
      daemonset:
        useHostPort: true
EOF

wget -q -P /var/lib/rancher/k3s/server/manifests/ https://github.com/jetstack/cert-manager/releases/download/v1.0.4/cert-manager.crds.yaml

cat > /var/lib/rancher/rke2/server/manifests/rancher.yaml << EOF
apiVersion: v1
kind: Namespace
metadata:
  name: cattle-system
---
apiVersion: v1
kind: Namespace
metadata:
  name: cert-manager
  labels:
    certmanager.k8s.io/disable-validation: "true"
---
apiVersion: helm.cattle.io/v1
kind: HelmChart
metadata:
  name: cert-manager
  namespace: kube-system
spec:
  targetNamespace: cert-manager
  repo: https://charts.jetstack.io
  chart: cert-manager
  version: v1.0.4
  helmVersion: v3
---
apiVersion: helm.cattle.io/v1
kind: HelmChart
metadata:
  name: rancher
  namespace: kube-system
spec:
  targetNamespace: cattle-system
  repo: https://releases.rancher.com/server-charts/stable/
  chart: rancher
  set:
    hostname: $PUBLIC_IP.nip.io
    replicas: 1
    rancherImageTag: v2.5.9
    antiAffinity: required
  helmVersion: v3
EOF
```
