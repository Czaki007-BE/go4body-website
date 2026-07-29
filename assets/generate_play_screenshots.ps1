Add-Type -AssemblyName System.Drawing

# Play Console wymaga scisle proporcji 9:16 (lub 16:9) dla zrzutow telefonu.
# Nasze zrzuty sa 1080x2520 (2.333:1) - za "wysokie" wzgledem szerokosci,
# wiec Play je ucina. Zamiast ucinac tresc ekranu, dodajemy piony pasy tla
# po bokach (pillarbox), zeby osiagnac dokladnie 9:16 bez utraty tresci.

$srcDir = "C:\Dev\go4body-website\assets"
$outDir = "C:\Dev\go4body-website\assets\play-listing"
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

$files = @('screen_health.jpg','screen_diet.jpg','screen_training.jpg','screen_body.jpg','screen_supplements.jpg','screen_coach.jpg')

foreach ($f in $files) {
    $srcPath = Join-Path $srcDir $f
    $src = [System.Drawing.Image]::FromFile($srcPath)

    $srcW = $src.Width
    $srcH = $src.Height

    # Docelowa szerokosc canvasu, zeby wysokosc:szerokosc = 16:9 (czyli 9:16 portret)
    $targetW = [int][math]::Ceiling($srcH * 9.0 / 16.0)
    if ($targetW % 2 -ne 0) { $targetW++ }
    $targetH = $srcH

    $bmp = New-Object System.Drawing.Bitmap($targetW, $targetH)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic

    # Tlo dopasowane do ciemnego motywu appki (bez wizualnego szwu przy krawedziach zrzutu)
    $g.Clear([System.Drawing.Color]::FromArgb(255, 10, 10, 10))

    $drawX = [int](($targetW - $srcW) / 2)
    $g.DrawImage($src, $drawX, 0, $srcW, $srcH)

    $outPath = Join-Path $outDir $f
    $bmp.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Jpeg)

    $g.Dispose()
    $bmp.Dispose()
    $src.Dispose()

    Write-Host "$f -> ${targetW}x${targetH} (pad each side: $drawX px)"
}
