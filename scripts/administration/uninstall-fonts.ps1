$fonts = @(
    "MesloLGS NF Regular.ttf",
    "MesloLGS NF Bold.ttf",
    "MesloLGS NF Italic.ttf",
    "MesloLGS NF Bold Italic.ttf"
)

$fontsDir = "$env:SystemRoot\Fonts"
$regPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"

Write-Host "Uninstalling MesloLGS NF fonts..." -ForegroundColor Cyan

foreach ($font in $fonts) {
    $fontPath = Join-Path $fontsDir $font

    # Remove the font file
    if (Test-Path $fontPath) {
        try {
            Remove-Item -Path $fontPath -Force
            Write-Host "Removed font file: $font"
        } catch {
            Write-Warning "Failed to remove font file: $font. Error: $_"
        }
    } else {
        Write-Host "Font file not found: $font"
    }

    # Build registry entry name
    $friendlyName = $font -replace 'MesloLGS NF ', '' -replace '.ttf', ''
    $regName = "MesloLGS NF ($friendlyName) (TrueType)"

    # Remove the registry entry
    if (Test-Path "$regPath\$regName") {
        try {
            Remove-ItemProperty -Path $regPath -Name $regName -Force
            Write-Host "Removed registry entry: $regName"
        } catch {
            Write-Warning "Failed to remove registry entry: $regName. Error: $_"
        }
    } else {
        Write-Host "Registry entry not found: $regName"
    }
}

Write-Host "MesloLGS NF fonts uninstalled successfully." -ForegroundColor Green
Write-Host "You may need to restart Windows Terminal or reboot your system to see changes." -ForegroundColor Yellow