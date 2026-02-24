Invoke-Expression (&starship init powershell)

Function ll { eza -la --git-ignore --hyperlink --total-size --time-style=iso }

Function ff {
    rga --color=always --line-number --no-heading --smart-case "$args" |
    fzf --ansi --color "hl:-1:underline,hl+:-1:underline:reverse" --delimiter : --preview 'bat --color=always {1} --highlight-line {2}'
}
