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


$Action = PromptYesNo('Do you want to active windows?')

if ($Action -eq $true) {
    Write-Host "Activating windows..."
    Invoke-RestMethod https://massgrave.dev/get | Invoke-Expression
}

Write-Host "Installing chocolatey..."
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

Remove-Module "PSReadLine" -Force
Install-Module "PSReadLine" -Force

refreshenv
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

Write-Host "Installing oh my posh..."
winget install JanDeDobbeleer.OhMyPosh -s winget

$Action = PromptYesNo('Do you want to intsall programs?')

if ($Action -eq $true) {
    Write-Host "Installing programs..."
    choco install .\Basic-choco-install.config -y
}

Write-Host "Setting execution policy..."
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

Write-Host "Installing PowerShell modules"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Set-PSRepository -Name 'PSGallery' -SourceLocation "https://www.powershellgallery.com/api/v2" -InstallationPolicy Trusted
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Add-Module "PSReadLine"
Add-Module "Posh-Git"
Add-Module "7Zip4PowerShell"


Write-Host "Installing terminal profiles..."
Copy-File-Safe .\Profile.ps1 "${HOME}\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
Copy-File-Safe .\Profile.ps1 "${HOME}\Documents\PowerShell\Microsoft.VSCode_profile.ps1"
Copy-File-Safe .\Profile.ps1 "${HOME}\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"

Write-Host "Installing terminal theme..."
Copy-File-Safe .\.vikesz-posh.omp.json "${HOME}\.vikesz-posh.omp.json"

Write-Host "Installing terminal settings..."
$WindowsTerminalFolder = Get-ChildItem "${env:LocalAppData}\Packages\" -Recurse | Where-Object { $_.PSIsContainer -and $_.Name.StartsWith("Microsoft.WindowsTerminal") }
$TerminalSettingsPath = "${WindowsTerminalFolder}\LocalState\settings.json"
Copy-File-Safe .\terminal-settings.json $TerminalSettingsPath

refreshenv
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

gsudo config PowerShellLoadProfile true

function PromptYesNo($Message) {
    $Action = $Host.UI.PromptForChoice('Select', $Message, ('&Yes', '&No'), 1)

    if ($Action -eq 0) {
        return $true
    }
    else {
        return $false
    }
}