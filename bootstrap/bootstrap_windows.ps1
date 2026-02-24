# Windows bootstrap script
# Run this in PowerShell as Administrator on a fresh machine.
# This script installs Git, configures WinRM for Ansible, and sets up WSL2.
# All package installation is then handled by Ansible via: just install-windows (from WSL2)

function Write-Step ($text) {
    Write-Host ""
    Write-Host -ForegroundColor Cyan "==> $text"
}

Write-Step "Updating WinGet"
winget upgrade --id Microsoft.AppInstaller --accept-source-agreements --silent

Write-Step "Installing Git"
winget install Git.Git --accept-source-agreements --accept-package-agreements --silent
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + `
            [System.Environment]::GetEnvironmentVariable("Path", "User")

Write-Step "Configuring WinRM for Ansible"
# WinRM requires a non-Public network profile; set any Public adapters to Private
Get-NetConnectionProfile | Where-Object NetworkCategory -eq 'Public' | Set-NetConnectionProfile -NetworkCategory Private
Enable-PSRemoting -Force -SkipNetworkProfileCheck
winrm set winrm/config/service/auth '@{Basic="true"}'
Set-Item -Path WSMan:\localhost\Service\AllowUnencrypted -Value $true
netsh advfirewall firewall add rule name="WinRM HTTP" protocol=TCP dir=in localport=5985 action=allow | Out-Null
Write-Host "WinRM configured on port 5985."

Write-Step "Setting up WSL2"
try {
    if (Get-Command wsl -ErrorAction Stop) {
        Write-Host "Updating WSL..."
        wsl --update
    }
} catch {
    Write-Host "Installing WSL (a restart will be required)..."
    wsl --install
}

Write-Host ""
Write-Host -ForegroundColor Green "Bootstrap complete!"
Write-Host ""
Write-Host "Next steps:"
Write-Host "  1. Restart if WSL2 was just installed."
Write-Host "  2. Open WSL2 and clone this repo."
Write-Host "  3. Run: bash bootstrap/bootstrap_ubuntu.sh   (installs Ansible and just)"
Write-Host "  4. Run: WINDOWS_PASSWORD=<your-password> just install-windows"
