Import-Module oh-my-posh
Import-Module PSReadLine
Set-PoshPrompt -Theme "${HOME}\.oh-my-posh.omp.json"
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
