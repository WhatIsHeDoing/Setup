function Write-Heading ($text)
{
    Write-Output ""
    Write-Host -ForegroundColor green $text
}

function Write-Title ($text)
{
    Write-Output ""
    Write-Host -BackgroundColor yellow -ForegroundColor blue $text
}

Write-Title "Setup"
Write-Heading "Configuring Chocolatey"

@("allowEmptyChecksumsSecure", "allowGlobalConfirmation") `
    | ForEach-Object { choco feature enable --name $_ }

Install-Module PSReadline -Confirm
Install-Module z -Confirm

$chocoConfig = Get-Content -Raw -Path .\chocolatey-apps.json | ConvertFrom-Json

function Install-FromChocolatey ($key)
{
    Write-Heading "Installing $key from Chocolatey"
    $chocoConfig.$key | ForEach-Object { cinst $_ }
}

Install-FromChocolatey "Tools"
Install-FromChocolatey "Languages"

Write-Heading "Configuring Git"
git config --global core.autocrlf true
git config --global credential.helper wincred

Write-Heading "Language extensions"
refreshenv
gem install jekyll bundler --no-document
npm install gulp -g
pip install flask
pip install pygments

Write-Heading "Configuring Windows"
Install-WindowsFeature -Name Web-Asp-Net

Install-FromChocolatey "Applications"

Write-Heading "Updating existing Chocolatey apps"
choco upgrade all

Write-Title "Done!"
Write-Output ""
