Add-Type -AssemblyName System.Drawing

$W = 1024
$H = 500
$bmp = New-Object System.Drawing.Bitmap($W, $H)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality

# Background base
$bgColor = [System.Drawing.Color]::FromArgb(255, 14, 14, 14)
$g.Clear($bgColor)

# Radial-ish orange glow (top-left area), approximated with PathGradientBrush
$glowPath = New-Object System.Drawing.Drawing2D.GraphicsPath
$glowPath.AddEllipse(-250, -300, 1100, 1100)
$glowBrush = New-Object System.Drawing.Drawing2D.PathGradientBrush($glowPath)
$glowBrush.CenterColor = [System.Drawing.Color]::FromArgb(60, 255, 140, 59)
$glowBrush.SurroundColors = @([System.Drawing.Color]::FromArgb(0, 255, 140, 59))
$g.FillPath($glowBrush, $glowPath)

# Subtle border
$borderPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 42, 42, 42), 2)
$g.DrawRectangle($borderPen, 1, 1, $W-3, $H-3)

# Icon (rounded square) on the left
$iconPath = "C:\Dev\go4body-website\assets\icon.png"
$iconSrc = [System.Drawing.Image]::FromFile($iconPath)
$iconSize = 260
$iconX = 90
$iconY = [int](($H - $iconSize) / 2)

function Get-RoundedRectPath($x, $y, $w, $h, $r) {
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $path.AddArc($x, $y, $r, $r, 180, 90)
    $path.AddArc($x + $w - $r, $y, $r, $r, 270, 90)
    $path.AddArc($x + $w - $r, $y + $h - $r, $r, $r, 0, 90)
    $path.AddArc($x, $y + $h - $r, $r, $r, 90, 90)
    $path.CloseFigure()
    return $path
}

$roundRadius = 56
$clipPath = Get-RoundedRectPath -x $iconX -y $iconY -w $iconSize -h $iconSize -r $roundRadius
$g.SetClip($clipPath)
$g.DrawImage($iconSrc, $iconX, $iconY, $iconSize, $iconSize)
$g.ResetClip()

# Subtle stroke around icon
$iconStroke = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(140, 255, 140, 59), 2)
$g.DrawPath($iconStroke, $clipPath)

# Text block to the right of icon
$textX = $iconX + $iconSize + 56
$titleFont = New-Object System.Drawing.Font("Segoe UI", 58, [System.Drawing.FontStyle]::Bold)
$titleBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 240, 240, 240))
$titleY = $iconY + 30
$g.DrawString("Go4Body", $titleFont, $titleBrush, $textX, $titleY)

$taglineFont = New-Object System.Drawing.Font("Segoe UI", 24, [System.Drawing.FontStyle]::Regular)
$taglineBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 160, 160, 160))
$g.DrawString("Trening - Dieta - AI Coach", $taglineFont, $taglineBrush, $textX, $titleY + 118)

$outPath = "C:\Dev\go4body-website\assets\feature-graphic.png"
$bmp.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)

$g.Dispose()
$bmp.Dispose()
$iconSrc.Dispose()

Write-Host "Saved: $outPath"
