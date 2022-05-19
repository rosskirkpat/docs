# How to enable ssh public key authentication for EC2 Windows instances via userdata

```powershell
<powershell>
mkdir C:\ProgramData\ssh\
Add-Content -Path C:\ProgramData\ssh\administrators_authorized_keys -Value @"
ssh-rsa <PUB_KEY>
"@
icacls.exe "C:\ProgramData\ssh\administrators_authorized_keys" /inheritance:r /grant "Administrators:F" /grant "SYSTEM:F"
</powershell>
```
