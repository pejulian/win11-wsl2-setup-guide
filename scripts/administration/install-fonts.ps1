$fonts = @(
    "MesloLGS NF Regular.ttf",
    "MesloLGS NF Bold.ttf",
    "MesloLGS NF Italic.ttf",
    "MesloLGS NF Bold Italic.ttf"
)

$baseUrl = "https://github.com/romkatv/powerlevel10k-media/raw/master"
$tempDir = "$env:TEMP\meslo-fonts"
$fontsDir = "$env:SystemRoot\Fonts"
$regPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"

if (-Not (Test-Path $tempDir)) {
    New-Item -Path $tempDir -ItemType Directory | Out-Null
}

Write-Host "Downloading MesloLGS NF fonts..." -ForegroundColor Cyan

foreach ($font in $fonts) {
    $escaped = $font -replace ' ', '%20'
    $url = "$baseUrl/$escaped"
    $destPath = Join-Path $tempDir $font

    Invoke-WebRequest -Uri $url -OutFile $destPath -UseBasicParsing
    Write-Host "Downloaded: $font"
}

Write-Host "Copying fonts to Windows Fonts directory and registering..." -ForegroundColor Cyan

foreach ($font in $fonts) {
    $sourcePath = Join-Path $tempDir $font
    $destPath = Join-Path $fontsDir $font

    Copy-Item -Path $sourcePath -Destination $destPath -Force

    # Build registry entry name
    $friendlyName = $font -replace 'MesloLGS NF ', '' -replace '.ttf', ''
    $regName = "MesloLGS NF ($friendlyName) (TrueType)"

    New-ItemProperty -Path $regPath -Name $regName -Value $font -PropertyType String -Force
    Write-Host "Registered: $regName"
}

Write-Host "MesloLGS NF fonts installed and registered successfully." -ForegroundColor Green
Write-Host "You may need to restart Windows Terminal or reboot your system to see changes." -ForegroundColor Yellow
