Set-Location C:\Users\user\261020_1027_Hokkaido
$ErrorActionPreference = "Stop"

$raw = (@("protocol=https","host=github.com","") -join "`n") | git credential fill
$token = ($raw | Select-String '^password=(.+)$').Matches.Groups[1].Value
if (-not $token) { throw "GitHub credential not found. Run: gh auth login" }
$env:GH_TOKEN = $token

Write-Host "[1/4] Ensuring public repo exists..."
gh repo view indadady/261020_1027_Hokkaido 2>$null
if ($LASTEXITCODE -ne 0) {
  gh repo create 261020_1027_Hokkaido --public --description "Jeongseon Economic Affairs Hokkaido smart guidebook"
}

Write-Host "[2/4] Pushing main..."
git remote set-url origin "https://github.com/indadady/261020_1027_Hokkaido.git"
git push -u origin main

Write-Host "[3/4] Enabling GitHub Pages..."
gh api "repos/indadady/261020_1027_Hokkaido/pages" 2>$null
if ($LASTEXITCODE -ne 0) {
  gh api -X POST "repos/indadady/261020_1027_Hokkaido/pages" -f build_type=legacy -f "source[branch]=main" -f "source[path]=/"
} else {
  gh api -X PUT "repos/indadady/261020_1027_Hokkaido/pages" -f build_type=legacy -f "source[branch]=main" -f "source[path]=/"
}

Write-Host "[4/4] Done"
Write-Host "https://indadady.github.io/261020_1027_Hokkaido/"
gh api "repos/indadady/261020_1027_Hokkaido/pages" --jq "{status:.status, url:.html_url}"
