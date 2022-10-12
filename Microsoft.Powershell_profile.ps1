Import-Module PSReadLine
oh-my-posh init pwsh --config "$HOME\vikesz-posh.omp.json" | Invoke-Expression
Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
# PowerShell parameter completion shim for the dotnet CLI
Register-ArgumentCompleter -Native -CommandName dotnet -ScriptBlock {
    param($commandName, $wordToComplete, $cursorPosition)
        dotnet complete --position $cursorPosition "$wordToComplete" | ForEach-Object {
           [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
}
function Set-GitConfig-Work {
    git config user.name "Bacskay Viktor"
    git config user.email "bacskay.viktor@autsoft.hu"
}
function Set-GitConfig-Personal {
    git config user.name "Bacskay Viktor"
    git config user.email "bacskay.viktor@gmail.com"
}

$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}