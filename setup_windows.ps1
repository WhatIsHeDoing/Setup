function Write-Heading ($text) {
    Write-Output ""
    Write-Host -ForegroundColor green $text
}

function Write-Title ($text) {
    Write-Output ""
    Write-Host -BackgroundColor yellow -ForegroundColor blue $text
}

Get-Content banner.txt
Write-Output ""

Write-Title "Updating Windows"
UsoClient /StartScan
UsoClient /StartDownload
UsoClient /StartInstall

Write-Title "Setting Up Scoop"
$chocoConfig = Get-Content -Raw -Path .\scoop-apps.json | ConvertFrom-Json

function Install-FromScoop ($key, $pin) {
    Write-Heading "Installing $key from Scoop"
    $chocoConfig.$key | ForEach-Object { scoop install $_ }

    if ($pin) {
        $chocoConfig.$key | ForEach-Object { scoop hold $_ }
    }
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

# Needed when adding buckets.
scoop install git

# Often needed by apps.
scoop install vcredist2022

Write-Heading "Configuring Git"
git config --global core.autocrlf true
git config --global credential.helper wincred
git config --global init.defaultBranch main
git config --global fetch.prune true
git lfs install

Install-FromScoop "Tools"
Install-FromScoop "Runtimes"
winget install Microsoft.DotNet.SDK.6 --accept-source-agreements --accept-package-agreements
Install-FromScoop "Pinned" $true

Write-Heading "Installing Windows 11 Visual Studio Build Tools"
winget install Microsoft.VisualStudio.2022.BuildTools --force --override "--wait --passive --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 --add Microsoft.VisualStudio.Component.Windows11SDK.22000"

Write-Heading "Installing and updating global language packages"
rustup update
cargo install cargo-outdated cargo-update diskonaut wasm-pack
cargo install-update -a
npm install -g npm@latest
python -m pip install --upgrade ipykernel pip pre-commit setuptools
minikube addons enable metrics-server

Install-FromScoop "Apps"

Write-Title "Setting Up"

Write-Heading "Updating apps"
scoop update *
winget upgrade --all --accept-source-agreements --accept-package-agreements

Write-Heading "Cleaning up Scoop"
scoop cleanup *

Write-Heading "Copying PowerShell Profile"
Copy-Item powershell-profile.ps1 $PROFILE

Write-Heading "Setting Up VS Code"
code --install-extension sdras.night-owl

Try {
    If (Get-Command wsl) {
        Write-Heading "Updating Windows Subsystem for Linux"
        wsl --update
    }
    Else {
        Write-Heading "Installing Windows Subsystem for Linux"
        wsl --install
    }
}
Catch {
    Write-Heading "Installing Windows Subsystem for Linux"
    wsl --install
}

Write-Heading "Configuring bottom (btm)"
Copy-Item .\config\bottom.toml (Join-Path $Env:AppData bottom\bottom.toml)

Write-Heading "Configuring Starship"
Copy-Item .\config\starship.toml (Join-Path $Env:UserProfile .config starship.toml)

Write-Title "Done!"
Write-Output ""
