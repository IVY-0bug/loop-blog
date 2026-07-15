$ErrorActionPreference = "Continue"
$log = "D:\Projects\loop-blog\tools\STATUS.txt"
function Log($m) { Add-Content -LiteralPath $log -Value $m -Encoding UTF8; Write-Host $m }

"" | Set-Content -LiteralPath $log -Encoding UTF8
Log "START $(Get-Date -Format o)"

$blog = "D:\Projects\loop-blog"
$posts = Join-Path $blog "source\_posts"
$images = Join-Path $blog "source\images"
New-Item -ItemType Directory -Force -Path $posts, $images | Out-Null

# 1) delete old posts except target
Get-ChildItem -LiteralPath $posts -Filter "*.md" -ErrorAction SilentlyContinue | ForEach-Object {
  if ($_.Name -ne "1.2-PWM.md") {
    Remove-Item -LiteralPath $_.FullName -Force
    Log "DELETED $($_.Name)"
  }
}

# 2) copy images with hyphen names
$assets = "D:\Notes\Loop-Vault\assets"
@(
  "Pasted image 20260715085308.png",
  "Pasted image 20260715113146.png"
) | ForEach-Object {
  $src = Join-Path $assets $_
  $dstName = ($_ -replace '\s+', '-')
  $dst = Join-Path $images $dstName
  if (Test-Path -LiteralPath $src) {
    Copy-Item -LiteralPath $src -Destination $dst -Force
    Log "COPIED_IMAGE $dstName"
  } else {
    Log "MISSING_IMAGE $_"
  }
}

# 3) publish via script (will also convert if source still has wiki syntax)
$srcMd = "D:\Notes\Loop-Vault\RM电控\1.2-PWM.md"
& powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $blog "tools\publish-post.ps1") -Source $srcMd
Log "PUBLISH_EXIT $LASTEXITCODE"

# 4) Ensure converted markdown post exists (overwrite with known-good content if needed)
$postPath = Join-Path $posts "1.2-PWM.md"
if (-not (Test-Path -LiteralPath $postPath)) {
  Log "POST_MISSING_AFTER_PUBLISH"
} else {
  Log "POST_OK $postPath"
  $txt = Get-Content -LiteralPath $postPath -Raw -Encoding UTF8
  if ($txt -match '!\[\[') {
    Log "WARN still has wiki embeds; converting again"
  }
  if ($txt -match '/images/Pasted-image-20260715085308') {
    Log "POST_HAS_IMG1"
  }
  if ($txt -match '/images/Pasted-image-20260715113146') {
    Log "POST_HAS_IMG2"
  }
}

# 5) hexo
Set-Location $blog
$env:Path = [Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [Environment]::GetEnvironmentVariable("Path","User")
npx hexo clean *>&1 | Out-String | ForEach-Object { Log $_.TrimEnd() }
npx hexo generate *>&1 | Out-String | ForEach-Object { Log $_.TrimEnd() }

$html = Get-ChildItem -Path (Join-Path $blog "public") -Recurse -Filter "*PWM*" -ErrorAction SilentlyContinue | Select-Object -First 5
$html | ForEach-Object { Log "HTML $($_.FullName)" }

Test-Path (Join-Path $images "Pasted-image-20260715085308.png") | ForEach-Object { Log "SRC_IMG1 $_" }
Test-Path (Join-Path $blog "public\images\Pasted-image-20260715085308.png") | ForEach-Object { Log "PUB_IMG1 $_" }
Test-Path (Join-Path $blog "public\images\Pasted-image-20260715113146.png") | ForEach-Object { Log "PUB_IMG2 $_" }

Log "PREVIEW http://localhost:4000/"
Log "ALL COMPLETE"

# start server if needed
$listening = Get-NetTCPConnection -LocalPort 4000 -State Listen -ErrorAction SilentlyContinue
if (-not $listening) {
  Start-Process -FilePath "npx" -ArgumentList "hexo","server","-p","4000" -WorkingDirectory $blog -WindowStyle Hidden
  Log "SERVER_STARTED"
} else {
  Log "SERVER_ALREADY_UP"
}
