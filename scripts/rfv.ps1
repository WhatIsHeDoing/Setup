<#
  .SYNOPSIS
  Finds all files with contents using ripgrep and displays the matching files for review using fzf and bat.

  .DESCRIPTION
  https://github.com/junegunn/fzf/blob/master/ADVANCED.md#using-fzf-as-interactive-ripgrep-launcher

  .INPUTS
  Contents of the files you would like to finds.

  .OUTPUTS
  None.

  .EXAMPLE
  PS> rfv scoop
#>

rg --color=always --line-number --no-heading --smart-case "$args" |
fzf --ansi --color "hl:-1:underline,hl+:-1:underline:reverse" --delimiter : --preview 'bat --color=always {1} --highlight-line {2}'
