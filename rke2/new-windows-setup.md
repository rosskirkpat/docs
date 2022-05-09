```powershell
powershell -Command "Start-Process PowerShell -Verb RunAs"

# if the above command fails to run, use this below
powershell 

# disable all of the firewalls
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False

Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# ensure choco is the latest version
choco upgrade chocolatey

# if you don't have ssh already enabled, install openssh
choco install openssh -y -params '"/SSHServerFeature"'

# after every choco install, run this to ensure your path is up to date
refreshenv

#  other things you can install
# https://community.chocolatey.org/packages

choco install golang --version 1.17.7 -y
choco install kubernetes-helm --version 3.8.0 -y
choco install vim -y
```
