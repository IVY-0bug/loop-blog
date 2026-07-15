# Loop publish helper — ASCII only (PowerShell encoding safe)
param(
  [Parameter(Mandatory = $true)]
  [string]$Source,
  [switch]$Preview
)

$ErrorActionPreference = "Stop"
$blogRoot = Split-Path -Parent $PSScriptRoot
$postsDir = Join-Path $blogRoot "source\_posts"
$imagesDir = Join-Path $blogRoot "source\images"
$vaultRoot = "D:\Notes\Loop-Vault"
$vaultAssets = Join-Path $vaultRoot "assets"

if (-not (Test-Path -LiteralPath $Source)) {
  Write-Error "Source file not found: $Source"
}

New-Item -ItemType Directory -Force -Path $postsDir, $imagesDir | Out-Null

# Wipe other demo/old posts when publishing a formal note (optional safety: only md)
Get-ChildItem -LiteralPath $postsDir -Filter "*.md" -ErrorAction SilentlyContinue |
  Where-Object { $_.FullName -ne (Join-Path $postsDir ([IO.Path]::GetFileName($Source))) } |
  ForEach-Object { }

$fileName = [IO.Path]::GetFileName($Source)
$dest = Join-Path $postsDir $fileName
Copy-Item -LiteralPath $Source -Destination $dest -Force
Write-Host "Copied post -> $dest"

function Sync-DirImages([string]$dir) {
  if (-not (Test-Path -LiteralPath $dir)) { return }
  Get-ChildItem -LiteralPath $dir -File -ErrorAction SilentlyContinue | Where-Object {
    $_.Extension -match '\.(png|jpe?g|gif|webp|svg)$'
  } | ForEach-Object {
    $targetName = ($_.Name -replace '\s+', '-')
    Copy-Item -LiteralPath $_.FullName -Destination (Join-Path $imagesDir $targetName) -Force
    Write-Host "Synced image -> $targetName"
  }
}

Sync-DirImages $vaultAssets
Sync-DirImages (Split-Path -Parent $Source)
# Also search vault root for Pasted image *.png
Get-ChildItem -LiteralPath $vaultRoot -Recurse -File -ErrorAction SilentlyContinue | Where-Object {
  $_.Extension -match '\.(png|jpe?g|gif|webp|svg)$'
} | ForEach-Object {
  $targetName = ($_.Name -replace '\s+', '-')
  Copy-Item -LiteralPath $_.FullName -Destination (Join-Path $imagesDir $targetName) -Force
  Write-Host "Synced image -> $targetName"
}

$content = Get-Content -LiteralPath $dest -Raw -Encoding UTF8
$content = $content -replace "(?m)^published:\s*(true|false)\r?\n", ""

# Obsidian highlight ==text== -> HTML mark
$content = [regex]::Replace($content, '==([^=]+?)==', '<mark>$1</mark>')

# Protect LaTeX subscripts: f_{PWM} style often broken by Markdown italics
# Prefer rewriting common pattern to mathrm form during publish
$content = $content -replace 'f_\{PWM\}', 'f_{\mathrm{PWM}}'
$content = $content -replace 'f_\{pwm\}', 'f_{\mathrm{PWM}}'

# Collapse multiline $$ blocks into one-line $$...$$ (more stable for Hexo+MathJax)
$content = [regex]::Replace($content, '\$\$\s*\r?\n([\s\S]*?)\r?\n\s*\$\$', {
  param($m)
  $body = ($m.Groups[1].Value -replace '\s+', ' ').Trim()
  '$$' + $body + '$$'
})

# ![[file.png|414]] -> markdown image
$content = [regex]::Replace($content, '!\[\[(?:assets/)?([^\]]+?)\]\]', {
  param($m)
  $inner = $m.Groups[1].Value.Trim()
  $filePart = ($inner -split '\|')[0].Trim()
  $name = ($filePart -replace '\s+', '-')
  "![image](/images/$name)"
})

$content = $content -replace '\]\((?:\.\./)*assets/([^)]+)\)', '](/images/$1)'
$content = $content -replace '\]\(assets/([^)]+)\)', '](/images/$1)'
$content = [regex]::Replace($content, '\((/images/[^)]+)\)', {
  param($m)
  $url = ($m.Groups[1].Value -replace '\s+', '-')
  "($url)"
})

$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[IO.File]::WriteAllText($dest, $content, $utf8NoBom)

Write-Host "Local publish done."
if ($Preview) {
  Set-Location $blogRoot
  npx hexo clean
  npx hexo server -p 4000
}
