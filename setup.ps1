function Write-Heading ($text) {
    Write-Output ""
    Write-Host -ForegroundColor green $text
}

function Write-Title ($text) {
    Write-Output ""
    Write-Host -BackgroundColor yellow -ForegroundColor blue $text
}

Write-Title "Setup"
Write-Heading "Configuring Chocolatey"

@("allowEmptyChecksumsSecure", "allowGlobalConfirmation") `
| ForEach-Object { choco feature enable --name $_ }

$chocoConfig = Get-Content -Raw -Path .\chocolatey-apps.json | ConvertFrom-Json

function Install-FromChocolatey ($key) {
    Write-Heading "Installing $key from Chocolatey"
    $chocoConfig.$key | ForEach-Object { cinst $_ }
}

Install-FromChocolatey "Tools"
Install-FromChocolatey "Languages"

Write-Heading "Configuring Git"
git config --global core.autocrlf true
git config --global credential.helper wincred
git config --global init.defaultBranch mai

Write-Heading "Installing Modules"
Install-Module oh-my-posh -Confirm
Install-Module posh-git -Confirm
Install-Module PSReadline -Confirm
Install-Module z -Confirm

Write-Heading "Installing modules for languages"
refreshenv
gem install bundler wdm --no-document
python -m pip install --upgrade pip

Install-FromChocolatey "Applications"

Write-Heading "Updating existing Chocolatey apps"
choco upgrade all

Write-Heading "Copying PowerShell Profile"
Copy-Item powershell-profile.ps1 $PROFILE

Write-Heading "Installing Fonts"
iwr -useb get.scoop.sh | iex
scoop install aria2
scoop bucket add nerd-fonts
scoop install sudo
sudo scoop install Delugia-Code

Write-Title "Done!"
Write-Output ""
