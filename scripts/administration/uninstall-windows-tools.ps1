# Uninstall all Chocolatey packages except Chocolatey itself
choco list --localonly | Where-Object { $_ -and ($_ -split ' ')[0] -match '^\w+$' } | ForEach-Object {
    $pkg = ($_ -split ' ')[0]
    if ($pkg -ne 'Chocolatey') {
        try {
            choco uninstall $pkg -y --remove-dependencies --no-progress -r -ErrorAction SilentlyContinue
        } catch {
            Write-Output "Skipped package: $pkg (may not be installed or already removed)"
        }
    }
}

# Kill any Chocolatey background processes
Get-Process choco* -ErrorAction SilentlyContinue | Stop-Process -Force

# Remove Chocolatey directory
$chocoPath = "$env:ProgramData\chocolatey"
if (Test-Path $chocoPath) {
    Remove-Item -Path $chocoPath -Recurse -Force
    Write-Output "Removed Chocolatey directory."
}

# Remove environment variables and PATH entries
[Environment]::SetEnvironmentVariable("ChocolateyInstall", $null, "Machine")

$envPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
$newPath = $envPath -replace [regex]::Escape("C:\ProgramData\chocolatey\bin;?"), ""
[Environment]::SetEnvironmentVariable("Path", $newPath, "Machine")

Write-Output "Chocolatey and its packages uninstalled."
 