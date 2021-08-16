
# WIP
# etcd only rke2 nodes 

## Hidden flags for rke2
```
disable-apiserver
disable-etcd
```


## controlplane only
### /etc/rancher/rke2/config.yaml

```yaml
cni: calico
disable-etcd: true
```


## etcd only
### /etc/rancher/rke2/config.yaml

```yaml
cni: calico
disable-apiserver: true
disable-kube-proxy: true
disable-cloud-controller: true
disable-scheduler: true
disable:
    - rke2-coredns
    - rke2-ingress-nginx
    - rke2-kube-proxy
    - rke2-metrics-server
```

-------

# etcd only
# repeat on three nodes

```shell
mkdir -p /etc/rancher/rke2
touch /etc/rancher/rke2/config.yaml
cat > /etc/rancher/rke2/config.yaml <<EOF
cni: "calico"
disable-apiserver: true
disable-kube-proxy: true
disable-cloud-controller: true
disable-scheduler: true
disable:
    - rke2-coredns
    - rke2-ingress-nginx
    - rke2-kube-proxy
    - rke2-metrics-server
EOF


export INSTALL_RKE2_VERSION="v1.21.3-rc6+rke2r2"
curl -sfL https://get.rke2.io | sh - 

systemctl enable rke2-server.service
systemctl start rke2-server.service

export PATH=$PATH:/var/lib/rancher/rke2/bin/
export KUBECONFIG="/etc/rancher/rke2/rke2.yaml"
crictl config --set runtime-endpoint=unix:///run/k3s/containerd/containerd.sock

FILE="/var/lib/rancher/rke2/server/node-token"
for F IN $FILE
    if [ !-f /var/lib/rancher/rke2/server/node-token]; then
    sleep 5 
    fi
cat /var/lib/rancher/rke2/server/node-token

curl -o /usr/local/bin/calicoctl -O -L  "https://github.com/projectcalico/calicoctl/releases/download/v3.19.2/calicoctl" 
chmod +x /usr/local/bin/calicoctl

# download etcdctl
wget https://github.com/etcd-io/etcd/releases/download/v3.4.16/etcd-v3.4.16-linux-amd64.tar.gz
tar -xvzf etcd-v3.4.16-linux-amd64.tar.gz etcd-v3.4.16-linux-amd64/etcdctl 
mv etcd-v3.4.16-linux-amd64/etcdctl /usr/local/bin/etcdctl

# check etcd
 etcdctl --cert="/var/lib/rancher/rke2/server/tls/etcd/server-client.crt" --key="/var/lib/rancher/rke2/server/tls/etcd/server-client.key" --endpoints https://127.0.0.1:2379 --cacert="/var/lib/rancher/rke2/server/tls/etcd/server-ca.crt" member list

```


# controlplane only
# repeat on three nodes
```shell
mkdir -p /etc/rancher/rke2
touch /etc/rancher/rke2/config.yaml
cat > /etc/rancher/rke2/config.yaml <<EOF
cni: "calico"
disable-etcd: true
EOF

export INSTALL_RKE2_VERSION="v1.21.3-rc6+rke2r2"
curl -sfL https://get.rke2.io | sh - 

systemctl enable rke2-server.service
systemctl start rke2-server.service

export PATH=$PATH:/var/lib/rancher/rke2/bin/
export KUBECONFIG="/etc/rancher/rke2/rke2.yaml"
crictl config --set runtime-endpoint=unix:///run/k3s/containerd/containerd.sock

FILE="/var/lib/rancher/rke2/server/node-token"
for F IN $FILE
    if [ !-f /var/lib/rancher/rke2/server/node-token]; then
    sleep 5 
    fi
cat /var/lib/rancher/rke2/server/node-token

curl -o /usr/local/bin/calicoctl -O -L  "https://github.com/projectcalico/calicoctl/releases/download/v3.19.2/calicoctl" 
chmod +x /usr/local/bin/calicoctl
```