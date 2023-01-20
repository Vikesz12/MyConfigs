#Requires -RunAsAdministrator

function Add-Module {
    param([Parameter(Mandatory = $true)][string]$ModuleName)

    if (Get-Module -ListAvailable -Name $ModuleName) {
    } 
    else {
        Write-Host "Installing module ${ModuleName}"
        Install-Module $ModuleName -Force
    }
}

function Copy-File-Safe {
    param (
        [Parameter(Mandatory = $true)][string]$Source,
        [Parameter(Mandatory = $true)][string]$Destination
    )
    
    New-Item -ItemType File -Path $Destination -Force | Out-Null
    Copy-Item $Source $Destination -Force -Verbose
}

function CheckIfGpuNameContains($Manufacturer) {
    return (Get-WmiObject win32_VideoController).Name -like "*$Manufacturer*"
}

function PromptYesNo($Message) {
    $Action = $Host.UI.PromptForChoice('Select', $Message, ('&Yes', '&No'), 1)

    if ($Action -eq 0) {
        return $true
    }
    else {
        return $false
    }
}

function Get-FileIn-ScriptDirectory($FileName) { 
    return Join-Path $PSScriptRoot  $FileName
}

Write-Host "Setting execution policy..."
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

$Action = PromptYesNo('Do you want to active windows?')

if ($Action -eq $true) {
    Write-Host "Activating windows..."
    Invoke-RestMethod https://massgrave.dev/get | Invoke-Expression
}

Write-Host "Installing windows terminal..."
winget install Microsoft.WindowsTerminal -l US --accept-source-agreements
Write-Host "Installing oh my posh..."
winget install JanDeDobbeleer.OhMyPosh -s winget

Write-Host "Installing chocolatey..."
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Set-PSRepository -Name 'PSGallery' -SourceLocation "https://www.powershellgallery.com/api/v2" -InstallationPolicy Trusted
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force

Remove-Module "PSReadLine" -Force
Install-Module "PSReadLine" -Force
Install-Module "posh-git" -Force

refreshenv
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")


Write-Host "Installing gpu drivers..."
if (CheckIfGpuNameContains("nvidia")) {
    Write-Host "Detected nvidia gpu installing driver..."
    choco install nvidia-display-driver -y
}
elseif (CheckIfGpuNameContains("amd")) {
    Write-Warning "Amd graphics card found please install gpu driver manually!"
}
elseif (CheckIfGpuNameContains("intel")) {
    Write-Host "Detected intel gpu installing driver..."
    choco install intel-graphics-driver -y
}
else {
    Write-Warning "Could not recognize gpu please install driver manually"
}

Write-Host "Installing essential programs..."
$EssentialsPath = Get-FileIn-ScriptDirectory("Essential-choco-install.config")
choco install $EssentialsPath -y

$Action = PromptYesNo('Do you want to intsall additional programs?')

if ($Action -eq $true) {
    Write-Host "Installing additional programs..."
    $AdditionalPaths = Get-FileIn-ScriptDirectory("Additional-choco-install.config")
    choco install $AdditionalPaths -y
}

Write-Host "Installing PowerShell modules"
Add-Module "PSReadLine"
Add-Module "Posh-Git"
Add-Module "7Zip4PowerShell"

Write-Host "Installing terminal profiles..."
$ProfilePath = Get-FileIn-ScriptDirectory("Microsoft.Powershell_profile.ps1")
Unblock-File $ProfilePath
Copy-File-Safe $ProfilePath "${HOME}\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
Copy-File-Safe $ProfilePath "${HOME}\Documents\PowerShell\Microsoft.VSCode_profile.ps1"
Copy-File-Safe $ProfilePath "${HOME}\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"

Write-Host "Installing terminal theme..."
$PoshPath = Get-FileIn-ScriptDirectory("vikesz-posh.omp.json")
Copy-File-Safe $PoshPath "${HOME}\vikesz-posh.omp.json"

Write-Host "Installing terminal settings..."
$WindowsTerminalFolder = Get-ChildItem "${env:LocalAppData}\Packages\" -Recurse | Where-Object { $_.PSIsContainer -and $_.Name.StartsWith("Microsoft.WindowsTerminal") }
$TerminalSettingsPath = "${env:LocalAppData}\Packages\${WindowsTerminalFolder}\LocalState\settings.json"
$TerminalSourcePath = Get-FileIn-ScriptDirectory("terminal-settings.json")
Copy-File-Safe $TerminalSourcePath $TerminalSettingsPath

refreshenv
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

gsudo config PowerShellLoadProfile true