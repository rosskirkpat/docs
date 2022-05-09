# Disaster Recovery - Recover cluster.rkestate and cluster.yml from RKE1 Snapshot 

## Tested with

rke v1.0.0  
v1.16.3-rancher1-1  
3 node local cluster all roles  
centos 7.9

## Recovery Scenario

end-user has lost the original cluster.rkestate and cluster.yml files and now the RKE1 cluster is hard down and they have access to etcd snapshots. We can rebuild the cluster.rkestate and cluster.yml files using the etcd snapshot in the case of a failing restore without them.

```console
# snapshots are stored remotely in /opt/rke/etcd-snapshots
rke etcd snapshot-save --config cluster.yml --name rke1-test-restore1

ssh centos@3.236.65.144 "sudo chown centos:centos /opt/rke/etcd-snapshots/rke1-test-restore1.zip"

scp centos@3.236.65.144:/opt/rke/etcd-snapshots/rke1-test-restore1.zip .


unzip rke1-test-restore1.zip && cd backup

# macosx
LC_ALL="C" grep --binary-files=text desiredState rke1-test-restore1 > extracted-state

# linux
grep desiredState rke1-test-restore1 -a > extracted-state

# edit the extracted-state file manually 
# and remove all characters before the first 
# `{` and then remove all characters after 
# the last `}`, including the double quotes
# to create a valid json file

# example

full-cluster-state��{"desiredState":{ -> {"desiredState":{

"configPath":""}}}}�"����������������������������������������������������������������������������������e���������������� ������s	�������	�����������������_�������� -> "configPath":""}}}}



cat extracted.rkestate | jq 

# You should see a large json output and no errors

cat extracted-state | jq > cluster.rkestate

# You now have the cluster.rkestate assembled from the snapshot, time to extract the cluster.yaml

cat cluster.rkestate | jq '.desiredState.rkeConfig'

cat cluster.rkestate | jq  '.desiredState.rkeConfig' > cluster.json

wget -q https://github.com/mikefarah/yq/releases/download/v4.24.3/yq_linux_amd64 -O /usr/bin/yq && chmod +x /usr/bin/yq

yq eval -P cluster.json > cluster.yaml


YAMLIFY=("internalAddress/internal_address" "dockerSocket/docker_socket" "sshKeyPath/ssh_key_path" "kubeApi/kube-api" "kubeController/kube-controller" "clusterDomain/cluster_domain" "infraContainerImage/infra_container_image" "clusterDnsServer/cluster_dns_server" "systemImages/system_images" "hostnameOverride/hostname_override" "sshAgentAuth/ssh_agent_auth" "ignoreDockerVersion/ignore_docker_version" "kubernetesVersion/kubernetes_version" "clusterName/cluster_name" "cloudProvider/cloud_provider" "prefixPath/prefix_path" "addonJobTimeout/addon_job_timeout" "bastionHost/bastion_host" "extraArgs/extra_args" "serviceClusterIpRange/service_cluster_ip_range" "serviceNodePortRange/service_node_port_range" "clusterCidr/cluster_cidr" "nginxProxy/nginx_proxy" "certDownloader/cert_downloader" "kubernetesServicesSidecar/kubernetes_services_sidecar" "kubednsSidecar/kubedns_sidecar" "kubednsAutoscaler/kubedns_autoscaler" "corednsAutoscaler/coredns_autoscaler" "flannelCni/flannel_cni" "calicoNode/calico_node" "calicoCni/calico_cni" "calicoControllers/calico_controllers" "calicoFlexVol/calico_flexvol" "canalNode/canal_node" "canalCni/canal_cni" "canalFlannel/canal_flannel" "canalFlexVol/canal_flexvol" "weaveNode/weave_node" "weaveCni/weave_cni" "podInfraContainer/pod_infra_container" "ingressBackend/ingress_backend" "metricsServer/metrics_server" "windowsPodInfraContainer/windows_pod_infra_container")

for y in $YAMLIFY; do
    sed -i "s/$y/g" cluster.yaml
done

# you should now have a valid cluster.yaml 
# and cluster.rkestate for attempting a restore

```
