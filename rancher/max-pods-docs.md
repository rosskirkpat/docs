# How to configure max pods for the SUSE Rancher Kubernetes distributions

## Considerations when Increasing the Max Pod Count

Changing the max-pods on an active cluster with workloads is generally a safe procedure when target number of max-pods is <=250. When the goal number of max-pods is >250, the additional considerations mentioned above require a deletion of all currently running pods.

If increasing max-pods to >250, there are additional considerations and changes required. The in-cluster IP management configuration needs to be modified as the default is a /16 split into one /24 for each node in the cluster. This comes to a limit of about 256 nodes with roughly 253 pods per node.

```console
--max-pods int32     Default: 110
    Number of Pods that can run on this Kubelet. (DEPRECATED: This parameter should be set via the config file specified by the Kubelet's --config flag. See https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/ for more information.)
```

## kubelet config file

```yml
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
maxPods: 250
```

## RKE1

### Modify the cluster.yaml

[Example RKE Full cluster.yml](https://rancher.com/docs/rke/latest/en/example-yamls/#full-cluster-yml-example)

```yml
rancher_kubernetes_engine_config:
    ...
    services:
        kubelet:
            extra_args:
                max-pods: 250
```

## RKE2

[RKE2 Configuration File](https://docs.rke2.io/install/install_options/install_options/#configuration-file)

### RKE2 Server

[RKE2 Server Configuration Options](https://docs.rke2.io/install/install_options/server_config/)

```shell
curl -sfL https://get.rke2.io | INSTALL_RKE2_TYPE="server" sh -

cat << EOF >> /etc/rancher/rke2/kubelet-server.config
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
maxPods: 250
EOF

cat << EOF >> /etc/rancher/rke2/config-server.yaml
write-kubeconfig-mode: "0644"
kubelet-arg: "/etc/rancher/rke2/kubelet-server.config"
EOF

rke2 server --config=/etc/rancher/rke2/config-server.yaml --kubelet-arg=config=/etc/rancher/rke2/kubelet.config
```

### RKE2 Agent

[RKE2 Agent Configuration Options](https://docs.rke2.io/install/install_options/linux_agent_config/)

```shell
curl -sfL https://get.rke2.io | INSTALL_RKE2_TYPE="agent" sh -

cat << EOF >> /etc/rancher/rke2/kubelet-agent.config
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
maxPods: 250
EOF

cat << EOF >> /etc/rancher/rke2/config-agent.yaml
write-kubeconfig-mode: "0644"
kubelet-arg: "/etc/rancher/rke2/kubelet-agent.config"
EOF

rke2 agent --config=/etc/rancher/rke2/config-agent.yaml --kubelet-arg=config=/etc/rancher/rke2/kubelet.config
```

## K3S

[K3S Configuration File](https://rancher.com/docs/k3s/latest/en/installation/install-options/how-to-flags/)

### k3s server

[K3S Server Configuration Options](https://rancher.com/docs/k3s/latest/en/installation/install-options/server-config/)

```shell
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server --kubelet-arg=config=/etc/rancher/k3s/kubelet-server.config" sh -

cat << EOF >> /etc/rancher/k3s/kubelet-server.config
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
maxPods: 250
EOF

cat << EOF >> /etc/rancher/k3s/config-server.yaml
write-kubeconfig-mode: "0644"
kubelet-arg: "/etc/rancher/k3s/kubelet-server.config"
EOF

k3s server --config=/etc/rancher/k3s/config-server.yaml --kubelet-arg=config=/etc/rancher/k3s/kubelet-server.config
```

### k3s agent

[K3S Agent Configuration Options](https://rancher.com/docs/k3s/latest/en/installation/install-options/agent-config/)

```shell
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="agent --kubelet-arg=config=/etc/rancher/k3s/kubelet-server.config" sh -

cat << EOF >> /etc/rancher/k3s/kubelet-agent.config
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
maxPods: 250
EOF


cat << EOF >> /etc/rancher/k3s/config-agent.yaml
write-kubeconfig-mode: "0644"
kubelet-arg: "/etc/rancher/k3s/kubelet-agent.config"
EOF

k3s agent --config=/etc/rancher/k3s/config-agent.yaml --kubelet-arg=config=/etc/rancher/k3s/kubelet-agent.config
```

**Note** You also have to reconfigure the k3s systemd service `/etc/systemd/system/k3s.service`

```conf
ExecStart=/usr/local/bin/k3s \
    server \
        '--disable' \
        'servicelb' \
        '--disable' \
        'traefik' \
        '--kubelet-arg=config=/etc/rancher/k3s/kubelet-server.config'
```
