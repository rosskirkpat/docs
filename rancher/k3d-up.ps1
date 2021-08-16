param (
    [Parameter()]
    [String]
    $Cluster,
    [Parameter()]
    [String]
    $VMIP,
    [Parameter()]
    [String]
    $K3dImage,
    [Parameter()]
    [String]
    $SshUser
)

function Rancher-on-k3d {
  [CmdletBinding()]
param (
    [Parameter()]
    [String]
    $Cluster,
    [Parameter()]
    [String]
    $VMIP,
    [Parameter()]
    [String]
    $K3dImage,
    [Parameter()]
    [String]
    $SshUser
)
  function Get-Args {
    if ($Cluster)
    {
        $env:K3D_CLUSTER = $Cluster
    }
  
    if ($VMIP)
    {
        $env:VM_IP = $VMIP
    }
  
    if ($K3dImage)
    {
        $env:K3D_IMAGE = $K3dImage
    }
    if ($SshUser)
    {
        $env:SSH_USER = $SshUser
    }
  }
  function Set-Environment
  {
      if (-Not $env:K3D_CLUSTER)
      {
        $env:K3D_CLUSTER = "rancher"
      }

      if (-Not $env:VM_IP)
      {
          $env:VM_IP = "X.X.X.X"
      }

      if (-Not $env:K3D_IMAGE)
      {
          $env:K3D_IMAGE = "v1.21.3-k3s1"
      }

      if (-Not $env:SSH_USER)
      {
          $env:SSH_USER = "ubuntu"
      }
  }

  function Run-Rancher() {
    Get-Args
    Set-Environment
    ssh $env:SSH_USER@$env:VM_IP "sudo curl -s https://raw.githubusercontent.com/rancher/k3d/main/install.sh | bash"
    ssh $env:SSH_USER@$env:VM_IP "sudo k3d cluster list"
    ssh $env:SSH_USER@$env:VM_IP "sudo k3d cluster delete $env:K3D_CLUSTER"
    ssh $env:SSH_USER@$env:VM_IP "sudo k3d cluster create $env:K3D_CLUSTER --k3s-server-arg "--kube-proxy-arg=conntrack-max-per-core=0" --k3s-agent-arg "--kube-proxy-arg=conntrack-max-per-core=0" --image=docker.io/rancher/k3s:$env:K3D_IMAGE --api-port=`$(hostname -I | awk '{print `$1}'):6443"
    $kubeconfig = $(ssh $env:SSH_USER@$env:VM_IP "sudo k3d kubeconfig get $env:K3D_CLUSTER")
    Set-Content -Path \\wsl$\Ubuntu\home\$env:SSH_USER\kubeconfig.yml -Value $kubeconfig
    ssh $env:SSH_USER@$env:VM_IP "export KUBECONFIG='~/kubeconfig.yaml'"
    ssh $env:SSH_USER@$env:VM_IP "sudo kubectl config use-context k3d-$env:K3D_CLUSTER"
    ssh $env:SSH_USER@$env:VM_IP "sudo kubectl cluster-info"
  }
Run-Rancher
}
Rancher-on-k3d @PSBoundParameters
