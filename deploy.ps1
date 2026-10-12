# Lädt die Website verschlüsselt zum Webhoster hoch – per FTPS (FTP über TLS) oder SFTP (SSH).
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
$proto = if ($cfg["PROTOKOLL"]) { $cfg["PROTOKOLL"].ToLower() } else { "ftps" }
if ($proto -notin "ftps", "sftp") { throw "PROTOKOLL muss ftps oder sftp sein" }
$pflicht = if ($proto -eq "ftps") { "FTP_HOST", "FTP_USER", "FTP_PASS" } else { "FTP_HOST", "FTP_USER" }
foreach ($k in $pflicht) { if (-not $cfg[$k]) { throw "$k fehlt in deploy.env" } }
$remoteDir = if ($cfg["FTP_DIR"]) { $cfg["FTP_DIR"].TrimEnd("/") } else { "" }

# Nur diese Dateien/Ordner gehören auf den Server
$include = @("index.html", "impressum.html", "datenschutz.html", ".htaccess", "robots.txt", "assets")
$exclude = @("assets\img\original")

$files = foreach ($item in $include) {
  $p = Join-Path $root $item
  if (Test-Path $p -PathType Leaf) { Get-Item -Force $p }
  elseif (Test-Path $p) { Get-ChildItem -Force -Recurse -File $p }
}
$files = @($files | Where-Object {
  $rel = $_.FullName.Substring($root.Length + 1)
  -not ($exclude | Where-Object { $rel.StartsWith($_) })
})
$rels = @($files | ForEach-Object { $_.FullName.Substring($root.Length + 1).Replace("\", "/") })

Write-Host "$($files.Count) Dateien -> $($proto)://$($cfg.FTP_HOST)$remoteDir/"
if ($DryRun) { $rels | ForEach-Object { Write-Host "  [dry] $_" }; return }

if ($proto -eq "ftps") {
  # FTPS: TLS ist Pflicht (--ssl-reqd) – ohne Verschlüsselung bricht der Upload ab.
  # --tls-max 1.2: Mit TLS 1.3 bricht die Datenverbindung zwischen Windows (Schannel) und dem
  # ALL-INKL-Server ab (Fehler 426, Datei kommt mit 0 Byte an). TLS 1.2 ist weiterhin sicher.
  for ($i = 0; $i -lt $files.Count; $i++) {
    Write-Host "  $($rels[$i])"
    # bis zu 3 Versuche – einzelne Verbindungsabbrüche kommen vor
    for ($versuch = 1; $versuch -le 3; $versuch++) {
      & curl.exe --silent --show-error --ssl-reqd --tls-max 1.2 --ftp-create-dirs `
        --user "$($cfg.FTP_USER):$($cfg.FTP_PASS)" -T $files[$i].FullName "ftp://$($cfg.FTP_HOST)$remoteDir/$($rels[$i])"
      if ($LASTEXITCODE -eq 0) { break }
      # Bei manchen Dateien bleibt die Abschlussmeldung des Servers aus, obwohl die Datei vollständig
      # angekommen ist (curl-Fehler 56). Dann zählt die Dateigröße auf dem Server.
      $kopf = & curl.exe --silent --ssl-reqd --tls-max 1.2 -I `
        --user "$($cfg.FTP_USER):$($cfg.FTP_PASS)" "ftp://$($cfg.FTP_HOST)$remoteDir/$($rels[$i])" | Out-String
      if ($kopf -match 'Content-Length:\s*(\d+)' -and [int64]$Matches[1] -eq $files[$i].Length) {
        Write-Host "    (Abschlussmeldung fehlte, Datei aber vollständig angekommen)"
        $global:LASTEXITCODE = 0
        break
      }
      Write-Host "    Versuch $versuch fehlgeschlagen, wiederhole …"
      Start-Sleep -Seconds 2
    }
    if ($LASTEXITCODE -ne 0) { throw "Upload fehlgeschlagen: $($rels[$i])" }
  }
}
else {
  # SFTP: Anmeldung per SSH-Schlüssel (kein Passwort in deploy.env nötig)
  $ziel = if ($remoteDir) { $remoteDir } else { "." }
  $alleDirs = $rels | Where-Object { $_.Contains("/") } | ForEach-Object {
    $teile = $_.Split("/")
    for ($n = 1; $n -lt $teile.Count; $n++) { ($teile[0..($n - 1)] -join "/") }
  } | Sort-Object -Unique | Sort-Object { $_.Split("/").Count }
  $batch = @()
  $alleDirs | ForEach-Object { $batch += "-mkdir `"$ziel/$_`"" }   # "-" = Fehler ignorieren, falls schon vorhanden
  $rels | ForEach-Object { $batch += "put `"$((Join-Path $root $_).Replace('\', '/'))`" `"$ziel/$_`"" }
  $batchFile = New-TemporaryFile
  Set-Content -Path $batchFile -Value $batch -Encoding ascii
  $sshArgs = @("-b", $batchFile.FullName, "-o", "StrictHostKeyChecking=accept-new")
  if ($cfg["SFTP_PORT"]) { $sshArgs += @("-P", $cfg["SFTP_PORT"]) }
  if ($cfg["SFTP_KEY"]) { $sshArgs += @("-i", $cfg["SFTP_KEY"]) }
  try {
    & sftp.exe @sshArgs "$($cfg.FTP_USER)@$($cfg.FTP_HOST)"
    if ($LASTEXITCODE -ne 0) { throw "SFTP-Upload fehlgeschlagen (Exit $LASTEXITCODE)" }
  }
  finally { Remove-Item $batchFile -Force }
}
Write-Host "Fertig."
