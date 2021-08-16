## the below will do new binary builds at runtime of rancher that reinitializes k3d

# k3d running in a linux hyperv VM
[k3d-up.ps1](https://github.com/rosskirkpat/docs/blob/main/rancher/k3d-up.ps1)


# rancher running in WSL linux distro image
### add to /etc/profile or /.bashrc 
### run with `sr`
```shell
#!/bin/bash
function sr {
        test ! -e /home/$WSL_USER/bin/rancher && cd /mnt/c/Users/$WIN_USER/repos/rancher && go build && cp /mnt/c/Users/$WIN_USER/repos/rancher/rancher ~/bin/
        test ! -e /home/$WSL_USER/bin/rancher-machine && cd /mnt/c/Users/$WIN_USER/repos/machine/scripts && ./build && cp /mnt/c/Users/$WIN_USER/repos/machine/bin/rancher-machine ~/bin/
        cd ~
        mkdir -p ~/bin
        test -e /home/$WSL_USER/bin/rancher && rm -f /home/$WSL_USER/bin/rancher
        cp /mnt/c/Users/$WIN_USER/bin/rancher /home/$WSL_USER/bin/
        chmod +x /home/$WSL_USER/bin/rancher
        test -e /home/$WSL_USER/bin/rancher-machine && rm -f /home/$WSL_USER/bin/rancher-machine
        cp /mnt/c/Users/$WIN_USER/bin/rancher-machine /home/$WSL_USER/bin/
        chmod +x /home/$WSL_USER/bin/rancher-machine
        CATTLE_BOOTSTRAP_PASSWORD=admin PATH=/home/$WSL_USER/bin CATTLE_DEV_MODE=30 KUBECONFIG=/home/$WSL_USER/kubeconfig.yml /home/$WSL_USER/bin/rancher --debug --no-cacerts
}
```


## SSH on your Windows agents
### Add to the userdata of your Windows nodes during provisioning

```powershell
# Install the OpenSSH Server
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0

# Start the sshd service
Start-Service sshd

# OPTIONAL but recommended:
Set-Service -Name sshd -StartupType 'Automatic'
```
