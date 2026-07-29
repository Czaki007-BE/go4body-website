Add-Type -AssemblyName System.Drawing

# Crop a 1024x500 landscape banner out of the existing splash-hero.png
# (dwie postacie + pomaranczowy pierscien, ten sam branding co splash/onboarding)

$srcPath = "C:\Dev\PaperclipProjects\Apps\Go4Body-APD190\go4body\assets\splash-hero.png"
$outPath = "C:\Dev\go4body-website\assets\feature-graphic.png"

$src = [System.Drawing.Image]::FromFile($srcPath)

$targetW = 1024
$targetH = 500

# Source crop: full width, centered vertically on the athletes + glow ring
$cropW = $src.Width
$cropH = [int]([double]$cropW / $targetW * $targetH)
$cropX = 0
$cropY = 537   # przesuniete tak, zeby zlapac ramiona/hantle + pierscien, nie logo na dole

$cropRect = New-Object System.Drawing.Rectangle(0, 0, $targetW, $targetH)

$bmp = New-Object System.Drawing.Bitmap($targetW, $targetH)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality

$srcRect = New-Object System.Drawing.Rectangle($cropX, $cropY, $cropW, $cropH)
$g.DrawImage($src, $cropRect, $srcRect, [System.Drawing.GraphicsUnit]::Pixel)

$bmp.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)

$g.Dispose()
$bmp.Dispose()
$src.Dispose()

Write-Host "Saved: $outPath"
