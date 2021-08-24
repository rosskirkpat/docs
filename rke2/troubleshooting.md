## Calico


### StrictAffinity 

```shell

curl -o /usr/local/bin/calicoctl -O -L  "https://github.com/projectcalico/calicoctl/releases/download/v3.19.1/calicoctl" 
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

```powershell
$Env:CONTAINER_RUNTIME_ENDPOINT = "npipe:////./pipe/containerd-containerd"
crictl.exe ps -a
```
