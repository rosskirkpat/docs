<#
.DESCRIPTION 
    Builds your fork of rancher/wins and runs the wins server in debug mode
.NOTES
    This script uses choco to install go and git if they are not available in your PATH.
.EXAMPLE
    wins-build-local.ps1 -Username rosskirkpat -Branch fix-wins 
    wins-build-local.ps1 -GitHubUsername rosskirkpat -Branch fix-wins -InstallVim
#>

param (
    [Parameter(Mandatory=$true)]
    [string]
    [Alias("GitHubUsername")]
    $Username,
    [Parameter(Mandatory=$true)]
    [String]
    $Branch,
    [Switch]
    $InstallVim
)

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
Set-StrictMode -Version Latest

function Confirm-Command ($cmdname) {
    return [bool](Get-Command -Name $cmdname -ErrorAction SilentlyContinue)
}

function Build-Wins {
    param ( 
    [CmdletBinding()]
    [Parameter(Mandatory=$true)]
    [string]
    $Username,
    [Parameter(Mandatory=$true)]
    [String]
    $Branch,
    [Switch]
    $InstallVim
    )

    if (-Not (Confirm-Command choco)) {
        Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
        $env:PATH+=";C:\ProgramData\chocolatey\bin"
    }

    if (-Not (Confirm-Command go)) {
        choco install golang --version 1.16.15 -y
        refreshenv
        $env:PATH+=";C:\Program Files\Go\bin"
    }

    if (-Not (Confirm-Command git)) {
        choco install git.install -y
        refreshenv
        $env:PATH+=";C:\Program Files\Git\bin"
    }

    if (-Not (Confirm-Command vim) -and $InstallVim)  {
        choco install vim -y
        refreshenv
    }

    try {
        git clone "https://github.com/$Username/wins" -b $Branch
        Push-Location -Path wins
        $COMMIT=$(git rev-parse HEAD)
        go.exe build -ldflags ('-s -w -X github.com/{0}/wins/pkg/defaults.AppVersion=dev -X github.com/{1}/wins/pkg/defaults.AppCommit={2} -extldflags "-static"' -f $Username, $Username, $COMMIT) -o bin/wins.exe cmd/main.go
        Write-Host -ForegroundColor Cyan -Message ("Successfully built wins from {0}/wins:{1} with commit ID {2}, now running wins server with debug enabled" -f $Username, $Branch, $COMMIT)
        .\bin\wins.exe --debug srv app run
    } catch {
        Pop-Location
        Write-Error -Message "Failed to successfully run wins-build-local.ps1"
    }
}

Build-Wins -Username $Username -Branch $Branch