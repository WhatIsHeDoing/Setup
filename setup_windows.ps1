function Write-Heading ($text) {
    Write-Output ""
    Write-Host -ForegroundColor green $text
}

function Write-Title ($text) {
    Write-Output ""
    Write-Host -BackgroundColor yellow -ForegroundColor blue $text
}

Write-Title "Updating Windows"
UsoClient /StartScan
UsoClient /StartDownload
UsoClient /StartInstall

Write-Title "Setting Up Scoop"
$chocoConfig = Get-Content -Raw -Path .\scoop-apps.json | ConvertFrom-Json

function Install-FromScoop ($key) {
    Write-Heading "Installing $key from Scoop"
    $chocoConfig.$key | ForEach-Object { scoop install $_ }
}

# https://devblogs.microsoft.com/scripting/use-a-powershell-function-to-see-if-a-command-exists/
Try {
    If (Get-Command scoop) {
        Write-Heading "Updating Scoop"
        scoop update
    }
    Else {
        Write-Heading "Installing Scoop"
        Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
        Invoke-WebRequest -useb get.scoop.sh | Invoke-Expression
    }
}
Catch {
    Write-Heading "Installing Scoop"
    Invoke-WebRequest -useb get.scoop.sh | Invoke-Expression
}

# Speeds up downloads.
scoop install aria2

# Needed when adding buckets.
scoop install git

# Often needed by apps.
scoop install vcredist2022

Write-Heading "Configuring Git"
git config --global core.autocrlf true
git config --global credential.helper wincred
git config --global init.defaultBranch main

Install-FromScoop "Tools"
Install-FromScoop "Languages"

Write-Heading "Installing Visual Studio Build Tools"
Invoke-WebRequest -Uri 'https://aka.ms/vs/17/release/vs_BuildTools.exe' -OutFile "$env:TEMP\vs_BuildTools.exe"
& "$env:TEMP\vs_BuildTools.exe" --passive --wait --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended --remove Microsoft.VisualStudio.Component.VC.CMake.Project

Write-Heading "Installing modules for languages"
python -m pip install --upgrade pip

Install-FromScoop "Apps"

Write-Title "Setting Up"

Write-Heading "Updating apps"
scoop update *
rustup update

Write-Heading "Cleaning up Scoop"
scoop cleanup *

Write-Heading "Copying PowerShell Profile"
Copy-Item powershell-profile.ps1 $PROFILE

Write-Heading "Setting Up VS Code"
code --install-extension sdras.night-owl

Write-Heading "Enabling Windows Subsystem for Linux"
wsl --install

Write-Title "Done!"
Write-Output ""
