Invoke-Expression (&starship init powershell)
Set-Alias rfv (Join-Path $HOME \rfv.ps1)
Function ll { eza -la --git-ignore --hyperlink --total-size --time-style=iso }
