# Lädt die Website per FTP(S) zum Webhoster hoch.
#
# Einmalig: deploy.env.example nach deploy.env kopieren und Zugangsdaten eintragen.
# (deploy.env ist in .gitignore und landet nie im Repository.)
#
# Aufruf:  powershell -ExecutionPolicy Bypass -File .\deploy.ps1
#          powershell -ExecutionPolicy Bypass -File .\deploy.ps1 -DryRun

param([switch]$DryRun)

$ErrorActionPreference = "Stop"
$root = $PSScriptRoot
$envFile = Join-Path $root "deploy.env"
if (-not (Test-Path $envFile)) { throw "deploy.env fehlt – bitte aus deploy.env.example anlegen." }

$cfg = @{}
Get-Content $envFile | Where-Object { $_ -match '^\s*([A-Z_]+)\s*=\s*(.*)\s*$' } | ForEach-Object {
  $cfg[$Matches[1]] = $Matches[2].Trim('"')
}
foreach ($k in "FTP_HOST", "FTP_USER", "FTP_PASS") { if (-not $cfg[$k]) { throw "$k fehlt in deploy.env" } }
$remoteDir = if ($cfg["FTP_DIR"]) { $cfg["FTP_DIR"].TrimEnd("/") } else { "" }

# Nur diese Dateien/Ordner gehören auf den Server
$include = @("index.html", "impressum.html", "datenschutz.html", ".htaccess", "robots.txt", "assets")
$exclude = @("assets\img\original")

$files = foreach ($item in $include) {
  $p = Join-Path $root $item
  if (Test-Path $p -PathType Leaf) { Get-Item -Force $p }
  elseif (Test-Path $p) { Get-ChildItem -Force -Recurse -File $p }
}
$files = $files | Where-Object {
  $rel = $_.FullName.Substring($root.Length + 1)
  -not ($exclude | Where-Object { $rel.StartsWith($_) })
}

Write-Host "$($files.Count) Dateien -> ftp://$($cfg.FTP_HOST)$remoteDir/"
foreach ($f in $files) {
  $rel = $f.FullName.Substring($root.Length + 1).Replace("\", "/")
  $url = "ftp://$($cfg.FTP_HOST)$remoteDir/$rel"
  if ($DryRun) { Write-Host "  [dry] $rel"; continue }
  Write-Host "  $rel"
  & curl.exe --silent --show-error --ssl-reqd --ftp-create-dirs `
    --user "$($cfg.FTP_USER):$($cfg.FTP_PASS)" -T $f.FullName $url
  if ($LASTEXITCODE -ne 0) { throw "Upload fehlgeschlagen: $rel" }
}
Write-Host "Fertig."
