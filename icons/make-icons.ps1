# Draws basket icons. Run: powershell -ExecutionPolicy Bypass -File icons\make-icons.ps1
Add-Type -AssemblyName System.Drawing

$here = $PSScriptRoot
$top = [System.Drawing.Color]::FromArgb(255, 194, 88, 58)
$bottom = [System.Drawing.Color]::FromArgb(255, 168, 65, 42)
$cream = [System.Drawing.Color]::FromArgb(255, 255, 246, 234)

function New-RoundRect([double]$x, [double]$y, [double]$w, [double]$h, [double]$r) {
  $path = New-Object System.Drawing.Drawing2D.GraphicsPath
  $d = $r * 2
  $path.AddArc([float]$x, [float]$y, [float]$d, [float]$d, 180, 90)
  $path.AddArc([float]($x + $w - $d), [float]$y, [float]$d, [float]$d, 270, 90)
  $path.AddArc([float]($x + $w - $d), [float]($y + $h - $d), [float]$d, [float]$d, 0, 90)
  $path.AddArc([float]$x, [float]($y + $h - $d), [float]$d, [float]$d, 90, 90)
  $path.CloseFigure()
  return $path
}

function New-Base([bool]$bleed, [double]$content) {
  $bmp = New-Object System.Drawing.Bitmap 1024, 1024
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
  $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
  $g.Clear([System.Drawing.Color]::Transparent)

  $full = New-Object System.Drawing.RectangleF 0, 0, 1024, 1024
  $brush = New-Object System.Drawing.Drawing2D.LinearGradientBrush $full, $top, $bottom, 45.0
  if ($bleed) {
    $g.FillRectangle($brush, $full)
  } else {
    $path = New-RoundRect 0 0 1024 1024 230
    $g.FillPath($brush, $path)
  }

  $g.TranslateTransform(512, 512)
  $g.ScaleTransform([float]$content, [float]$content)
  $g.TranslateTransform(-512, -512)

  $white = New-Object System.Drawing.SolidBrush $cream
  $pen = New-Object System.Drawing.Pen $cream, 44
  $pen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
  $pen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round

  # handle
  $g.DrawArc($pen, 328, 250, 368, 420, 180, 180)

  # basket body
  $body = New-Object System.Drawing.Drawing2D.GraphicsPath
  $points = @(
    (New-Object System.Drawing.PointF 252, 462),
    (New-Object System.Drawing.PointF 772, 462),
    (New-Object System.Drawing.PointF 690, 790),
    (New-Object System.Drawing.PointF 334, 790)
  )
  $body.AddPolygon($points)
  $g.FillPath($white, $body)

  # rim
  $rim = New-RoundRect 232 430 560 64 30
  $g.FillPath($white, $rim)

  # stripes in background color
  $bgPen = New-Object System.Drawing.Pen $bottom, 30
  $bgPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
  $bgPen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
  $g.DrawLine($bgPen, 430, 552, 412, 742)
  $g.DrawLine($bgPen, 512, 552, 512, 742)
  $g.DrawLine($bgPen, 594, 552, 612, 742)

  $g.Dispose()
  return $bmp
}

function Save-Resized($source, [int]$size, [string]$file) {
  $bmp = New-Object System.Drawing.Bitmap $size, $size
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
  $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
  $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
  $g.DrawImage($source, 0, 0, $size, $size)
  $bmp.Save((Join-Path $here $file), [System.Drawing.Imaging.ImageFormat]::Png)
  $g.Dispose()
  $bmp.Dispose()
  Write-Output "  $file"
}

$rounded = New-Base $false 1.12
$bleed = New-Base $true 0.92

$rounded.Save((Join-Path $here 'icon-1024.png'), [System.Drawing.Imaging.ImageFormat]::Png)
Save-Resized $rounded 512 'icon-512.png'
Save-Resized $rounded 192 'icon-192.png'
Save-Resized $rounded 32 'favicon-32.png'
Save-Resized $bleed 512 'icon-maskable-512.png'
Save-Resized $bleed 180 'apple-touch-icon.png'

$rounded.Dispose()
$bleed.Dispose()
Write-Output 'Done.'
