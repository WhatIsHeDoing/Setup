# Run in PowerShell as Administrator.

function Write-Step ($text) {
    Write-Output ""
    Write-Output -ForegroundColor Cyan "==> $text"
}

Write-Step "Updating WinGet"
winget upgrade --id Microsoft.AppInstaller --accept-source-agreements --silent

Write-Step "Installing Git"
winget install Git.Git --accept-source-agreements --accept-package-agreements --silent
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + `
            [System.Environment]::GetEnvironmentVariable("Path", "User")

Write-Step "Configuring WinRM for Ansible"
# WinRM refuses a Public network profile.
Get-NetConnectionProfile | Where-Object NetworkCategory -eq 'Public' | Set-NetConnectionProfile -NetworkCategory Private
Enable-PSRemoting -Force -SkipNetworkProfileCheck
winrm set winrm/config/service/auth '@{Basic="true"}'
# AllowUnencrypted is safe here: WSL2 reaches the host over the virtual
# loopback adapter, so the traffic never leaves the machine.
Set-Item -Path WSMan:\localhost\Service\AllowUnencrypted -Value $true
netsh advfirewall firewall add rule name="WinRM HTTP" protocol=TCP dir=in localport=5985 action=allow | Out-Null
Write-Output "WinRM configured on port 5985."

Write-Step "Setting up WSL2"
try {
    if (Get-Command wsl -ErrorAction Stop) {
        Write-Output "Updating WSL..."
        wsl --update
    }
} catch {
    Write-Output "Installing WSL (a restart will be required)..."
    wsl --install
}

Write-Output ""
Write-Output -ForegroundColor Green "Bootstrap complete!"
Write-Output ""
Write-Output "Next steps:"
Write-Output "  1. Restart if WSL2 was just installed."
Write-Output "  2. Open WSL2 and clone this repo."
Write-Output "  3. Run: bash bootstrap/bootstrap_ubuntu.sh   (installs Ansible and just)"
Write-Output "  4. Run: WINDOWS_PASSWORD=<your-password> just install"
