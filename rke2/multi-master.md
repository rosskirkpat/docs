#!/bin/bash
# rke2 server 1 (master)

mkdir -p /etc/rancher/rke2
touch /etc/rancher/rke2/config.yaml
echo 'cni: "calico"' > /etc/rancher/rke2/config.yaml

curl -sfL https://get.rke2.io | sh - 

systemctl enable rke2-server.service
systemctl start rke2-server.service

FILE="/var/lib/rancher/rke2/server/node-token"
for F IN $FILE
    if [ !-f /var/lib/rancher/rke2/server/node-token]; then
    sleep 5 
    fi
cat /var/lib/rancher/rke2/server/node-token

export PATH=$PATH:/var/lib/rancher/rke2/bin/
export KUBECONFIG="/etc/rancher/rke2/rke2.yaml"
crictl config --set runtime-endpoint=unix:///run/k3s/containerd/containerd.sock


curl -o /usr/local/bin/calicoctl -O -L  "https://github.com/projectcalico/calicoctl/releases/download/v3.19.2/calicoctl" 
chmod +x /usr/local/bin/calicoctl

----
# rke2 server 2 (cold master)

echo "cni: calico
server: https://<server>:9345
token: <token from server node> " >> /etc/rancher/rke2/config.yaml

curl -sfL https://get.rke2.io | sh - 

systemctl enable rke2-server.service
systemctl start rke2-server.service

export PATH=$PATH:/var/lib/rancher/rke2/bin/
export KUBECONFIG="/etc/rancher/rke2/rke2.yaml"
crictl config --set runtime-endpoint=unix:///run/k3s/containerd/containerd.sock

----
# rke2 server 3 (cold master)

echo "cni: calico
server: https://<server>:9345
token: <token from server node> " >> /etc/rancher/rke2/config.yaml

curl -sfL https://get.rke2.io | sh - 

systemctl enable rke2-server.service
systemctl start rke2-server.service

export PATH=$PATH:/var/lib/rancher/rke2/bin/
export KUBECONFIG="/etc/rancher/rke2/rke2.yaml"
crictl config --set runtime-endpoint=unix:///run/k3s/containerd/containerd.sock
