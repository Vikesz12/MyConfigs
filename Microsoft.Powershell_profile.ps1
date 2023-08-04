Import-Module PSReadLine
Import-Module posh-git

oh-my-posh init pwsh --config "$HOME\vikesz-posh.omp.json" | Invoke-Expression

Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward

function Set-GitConfig-Work {
    git config user.name "Bacskay Viktor"
    git config user.email "viktor.bacskay@asuratechnologies.com"
}

function Set-GitConfig-Personal {
    git config user.name "Bacskay Viktor"
    git config user.email "bacskay.viktor@gmail.com"
}

function Remove-Merged-Branches { git branch --merged | Select-String -NotMatch "(^\*|master|dev)" | ForEach-Object { git branch -d $_.ToString().Trim() } }

function Remove-Branches-No-Remote {
    git fetch -p
    git branch -vv | Select-String ': gone]' | ForEach-Object { git branch -D ($_ -split "\s+")[1].ToString().Trim() }
}

function Open-Vs {
    Get-ChildItem *.sln -Recurse | Invoke-Item
}

# Autocompletes

# chocolatey
Import-Module "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1" -Force
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
    Import-Module "$ChocolateyProfile"
}

# winget
Register-ArgumentCompleter -Native -CommandName winget -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)
    [Console]::InputEncoding = [Console]::OutputEncoding = $OutputEncoding = [System.Text.Utf8Encoding]::new()
    $Local:word = $wordToComplete.Replace('"', '""')
    $Local:ast = $commandAst.ToString().Replace('"', '""')
    winget complete --word="$Local:word" --commandline "$Local:ast" --position $cursorPosition | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}

# dotnet CLI
Register-ArgumentCompleter -Native -CommandName dotnet -ScriptBlock {
    param($commandName, $wordToComplete, $cursorPosition)
    dotnet complete --position $cursorPosition "$wordToComplete" | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}

# Nuke
Register-ArgumentCompleter -Native -CommandName nuke -ScriptBlock {
    param($commandName, $wordToComplete, $cursorPosition)
    nuke :complete "$wordToComplete" | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}