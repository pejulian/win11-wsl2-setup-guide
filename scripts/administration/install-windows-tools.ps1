# Install Chocolatey
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
iex ((New-Object System.Net.WebClient).DownloadString("https://community.chocolatey.org/install.ps1"))

Start-Sleep -Seconds 5

# Check if choco is available
if (Get-Command choco -ErrorAction SilentlyContinue) {
    Write-Output "Chocolatey installed successfully."

    # Install Git
    choco install git -y --no-progress
    if ($LASTEXITCODE -eq 0) {
        Write-Output "Git installed successfully."
    } else {
        Write-Error "Git installation failed."
    }

    # Install 7-Zip
    choco install 7zip -y --no-progress
    if ($LASTEXITCODE -eq 0) {
        Write-Output "7-Zip installed successfully."
    } else {
        Write-Error "7-Zip installation failed."
    }

} else {
    Write-Error "Chocolatey installation failed. Skipping package installs."
}
 