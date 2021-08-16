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
