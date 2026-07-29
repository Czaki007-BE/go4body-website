Add-Type -AssemblyName System.Drawing

# Zamiast ciasnego kadru (ucinal glowy/dlonie) - bierzemy wiekszy wycinek
# ze splash-hero.png i SKALUJEMY do wysokosci 500px zamiast ucinac,
# resztę canvasu (1024x500) wypelniamy tlem w tym samym stylu.

$srcPath = "C:\Dev\PaperclipProjects\Apps\Go4Body-APD190\go4body\assets\splash-hero.png"
$outPath = "C:\Dev\go4body-website\assets\feature-graphic.png"

$src = [System.Drawing.Image]::FromFile($srcPath)

$W = 1024
$H = 500

# Pionowy wycinek zrodla obejmujacy CALE sylwetki (od glow nad glowami do dloni z hantlami)
$srcCropY = 330
$srcCropH = 980
$srcCropX = 0
$srcCropW = $src.Width

# Skalujemy ten wycinek tak, zeby zmiescil sie w wysokosci canvasu (bez ucinania)
$scale = [double]$H / $srcCropH
$drawW = [int]([double]$srcCropW * $scale)
$drawH = $H
$drawX = [int](($W - $drawW) / 2)
$drawY = 0

$bmp = New-Object System.Drawing.Bitmap($W, $H)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality

# Tlo w tym samym ciemnym odcieniu co reszta brandingu
$g.Clear([System.Drawing.Color]::FromArgb(255, 10, 10, 10))

# Delikatna pomaranczowa poswiata w tle (spojna z pierscieniem na zdjeciu)
$glowPath = New-Object System.Drawing.Drawing2D.GraphicsPath
$glowPath.AddEllipse(($W/2) - 700, -400, 1400, 1400)
$glowBrush = New-Object System.Drawing.Drawing2D.PathGradientBrush($glowPath)
$glowBrush.CenterColor = [System.Drawing.Color]::FromArgb(35, 255, 140, 59)
$glowBrush.SurroundColors = @([System.Drawing.Color]::FromArgb(0, 255, 140, 59))
$g.FillPath($glowBrush, $glowPath)

$srcRect = New-Object System.Drawing.Rectangle($srcCropX, $srcCropY, $srcCropW, $srcCropH)
$dstRect = New-Object System.Drawing.Rectangle($drawX, $drawY, $drawW, $drawH)
$g.DrawImage($src, $dstRect, $srcRect, [System.Drawing.GraphicsUnit]::Pixel)

$bmp.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)

$g.Dispose()
$bmp.Dispose()
$src.Dispose()

Write-Host "Saved: $outPath (drawW=$drawW, padding each side=$drawX)"
