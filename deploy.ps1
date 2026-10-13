# Lädt die Website verschlüsselt zum Webhoster hoch – per FTPS (FTP über TLS) oder SFTP (SSH).
#
# Einmalig: deploy.env.example nach deploy.env kopieren und Zugangsdaten eintragen.
# (deploy.env ist in .gitignore und landet nie im Repository.)
#
# Aufruf:  powershell -ExecutionPolicy Bypass -File .\deploy.ps1
#          powershell -ExecutionPolicy Bypass -File .\deploy.ps1 -DryRun
#          powershell -ExecutionPolicy Bypass -File .\deploy.ps1 -Dev     (Testseite dev.kita-neufang.de)
#          powershell -ExecutionPolicy Bypass -File .\deploy.ps1 -Alles   (alle Dateien, nicht nur geänderte)
#
# Hochgeladen werden nur Dateien, die sich seit dem letzten Upload (Markierung "dev" bzw. "live",
# siehe unten) geändert haben. Gelöschte oder umbenannte Dateien bleiben auf dem Server liegen –
# das Skript nennt sie, entfernt werden sie von Hand.
#
# -Dev lädt dieselben Dateien nach DEV_DIR statt FTP_DIR. Statt .htaccess und robots.txt der
# Live-Seite kommen dort hin: tools/dev.htaccess (Passwortschutz, noindex, kein Cache),
# eine robots.txt, die alles sperrt, und eine .htpasswd aus DEV_USER/DEV_PASS. Dazu kommt
# aenderungen.html mit den letzten Commits (tools/aenderungen.ps1), Noch-nicht-Live hervorgehoben.
#
# Absicherung über Git: Nach jedem Upload zeigt die Markierung (Tag) "dev" bzw. "live" auf den
# hochgeladenen Commit. Live geht nur ein committeter Stand; weicht er von dem ab, was zuletzt auf
# der Testseite war, fragt das Skript nach (-Force überspringt die Frage).

param([switch]$DryRun, [switch]$Dev, [switch]$Force, [switch]$Alles)

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

# Git-Stand prüfen – nur die Dateien, die auch hochgeladen werden
$seite = @($include) + @($exclude | ForEach-Object { ":!" + $_.Replace("\", "/") })
$offen = @(& git -C $root status --porcelain -- $seite)
$devTag = & git -C $root rev-parse --short --verify --quiet "dev^{commit}"
if ($Dev) {
  if ($offen) { Write-Host "Hinweis: Nicht committete Änderungen werden mit hochgeladen; die Markierung 'dev' bleibt dabei unverändert." }
}
else {
  if ($offen) {
    Write-Host "Nicht committete Änderungen:"
    $offen | ForEach-Object { Write-Host "  $_" }
    if (-not $DryRun) { throw "Live geht nur ein committeter Stand – erst committen und mit -Dev testen." }
  }
  # Unterscheiden sich die Seiten-Dateien vom zuletzt auf der Testseite geprüften Stand?
  $getestet = $false
  if ($devTag) { & git -C $root diff --quiet $devTag HEAD -- $seite; $getestet = ($LASTEXITCODE -eq 0) }
  if (-not $getestet) {
    $stand = if ($devTag) { "Testseite zeigt Commit $devTag" } else { "noch nie mit -Dev hochgeladen" }
    Write-Host "WARNUNG: Dieser Stand war so noch nicht auf der Testseite ($stand)."
    if (-not $DryRun -and -not $Force) {
      if ((Read-Host "Trotzdem live hochladen? (j/n)") -notmatch '^[jJ]') { Write-Host "Abgebrochen."; return }
    }
  }
}

# Nur hochladen, was sich seit dem letzten Upload geändert hat (Vergleich mit der Markierung,
# einschließlich nicht committeter und neuer Dateien)
$marke = if ($Dev) { "dev" } else { "live" }
$letzter = & git -C $root rev-parse --short --verify --quiet "$marke^{commit}"
if ($Alles) { Write-Host "-Alles: alle Dateien werden hochgeladen." }
elseif (-not $letzter) { Write-Host "Noch kein Upload mit Markierung '$marke' – alle Dateien werden hochgeladen." }
else {
  $geaendert = @{}
  $geloescht = @()
  & git -C $root -c core.quotepath=off diff --name-status --no-renames $letzter -- $seite | ForEach-Object {
    $status, $pfad = $_ -split "`t", 2
    if ($status -eq "D") { $geloescht += $pfad } else { $geaendert[$pfad] = $true }
  }
  & git -C $root -c core.quotepath=off ls-files --others --exclude-standard -- $seite | ForEach-Object { $geaendert[$_] = $true }
  $alle = $files.Count
  $behalten = @(for ($i = 0; $i -lt $rels.Count; $i++) { if ($geaendert.ContainsKey($rels[$i])) { $i } })
  $files = @($behalten | ForEach-Object { $files[$_] })
  $rels = @($behalten | ForEach-Object { $rels[$_] })
  Write-Host "Seit '$marke' ($letzter) geändert: $($files.Count) von $alle Dateien (alle hochladen: -Alles)"
  if ($geloescht) {
    Write-Host "Hinweis: Diese Dateien sind lokal gelöscht/umbenannt, liegen aber noch auf dem Server:"
    $geloescht | ForEach-Object { Write-Host "  $_" }
  }
}

$utf8 = New-Object System.Text.UTF8Encoding($false)
$tmpDir = $null
if ($Dev) {
  foreach ($k in "DEV_DIR", "DEV_USER", "DEV_PASS", "DEV_HTPASSWD", "DEV_ZUGANG") { if (-not $cfg[$k]) { throw "$k fehlt in deploy.env" } }
  # steht im regulären Ausdruck der .htaccess – daher nur Buchstaben und Ziffern
  if ($cfg.DEV_ZUGANG -notmatch '^[A-Za-z0-9]{20,}$') { throw "DEV_ZUGANG: mindestens 20 Zeichen, nur Buchstaben und Ziffern" }
  $remoteDir = $cfg["DEV_DIR"].TrimEnd("/")

  # Live-.htaccess und -robots.txt gehören nicht auf die Testseite; index.html kommt unten mit
  # Testseiten-Link (immer, damit der Link auch bei unveränderter Startseite vorhanden ist)
  $behalten = @(for ($i = 0; $i -lt $rels.Count; $i++) { if ($rels[$i] -notin ".htaccess", "robots.txt", "index.html") { $i } })
  $files = @($behalten | ForEach-Object { $files[$_] })
  $rels = @($behalten | ForEach-Object { $rels[$_] })

  # Passwort-Hash (Apache-MD5) per OpenSSL – liegt Git für Windows bei
  $openssl = (Get-Command openssl.exe -ErrorAction SilentlyContinue).Source
  if (-not $openssl) {
    $openssl = @("$env:ProgramFiles\Git\mingw64\bin\openssl.exe", "$env:ProgramFiles\Git\usr\bin\openssl.exe") |
      Where-Object { Test-Path $_ } | Select-Object -First 1
  }
  if (-not $openssl) { throw "openssl.exe nicht gefunden (wird für die .htpasswd gebraucht; kommt mit Git für Windows)" }

  # Erzeugte Dateien ohne BOM schreiben (Apache verträgt kein BOM in .htaccess)
  $tmpDir = Join-Path ([IO.Path]::GetTempPath()) ("kita-dev-" + [guid]::NewGuid())
  New-Item -ItemType Directory $tmpDir | Out-Null

  # Passwort per Datei übergeben, nicht per Pipe: PowerShell setzt beim Pipen an Programme ein BOM
  # davor und ein Zeilenende dahinter – der Hash passte dann nicht zum Passwort.
  $pwDatei = Join-Path $tmpDir "pw.txt"
  [IO.File]::WriteAllText($pwDatei, $cfg.DEV_PASS, $utf8)
  $hash = & $openssl passwd -apr1 -in $pwDatei
  Remove-Item -Force $pwDatei
  if ($LASTEXITCODE -ne 0 -or -not $hash) { throw "Passwort-Hash konnte nicht erzeugt werden" }
  $erzeugt = [ordered]@{
    ".htaccess"  = (Get-Content -Raw -Encoding UTF8 (Join-Path $root "tools\dev.htaccess")).Replace("{{HTPASSWD}}", $cfg.DEV_HTPASSWD).Replace("{{ZUGANG}}", $cfg.DEV_ZUGANG)
    "robots.txt" = "User-agent: *`nDisallow: /`n"
    ".htpasswd"  = "$($cfg.DEV_USER):$hash`n"
    # Liste der letzten Commits: https://dev.kita-neufang.de/aenderungen.html
    "aenderungen.html" = & (Join-Path $root "tools\aenderungen.ps1") -NichtCommittet @($offen | ForEach-Object { $_.Substring(3) })
    # Startseite mit festem Knopf "Testseite · Änderungen" unten links (nur hier, nicht live)
    "index.html" = (Get-Content -Raw -Encoding UTF8 (Join-Path $root "index.html")).Replace("</body>",
      '<a href="aenderungen.html" style="position:fixed;left:12px;bottom:12px;z-index:60;background:#b23a2a;color:#fff;' +
      'font:700 14px/1.2 Nunito,sans-serif;padding:8px 14px;border-radius:99px;text-decoration:none;' +
      'box-shadow:0 4px 14px rgba(0,0,0,.25)">Testseite · Änderungen</a>' + "`n</body>")
  }
  foreach ($name in $erzeugt.Keys) {
    $pfad = Join-Path $tmpDir $name
    [IO.File]::WriteAllText($pfad, $erzeugt[$name], $utf8)
    $files += Get-Item -Force $pfad
    $rels += $name
  }
}

Write-Host "$($files.Count) Dateien -> $($proto)://$($cfg.FTP_HOST)$remoteDir/"
if ($DryRun) {
  $rels | ForEach-Object { Write-Host "  [dry] $_" }
  if ($tmpDir) { Remove-Item -Recurse -Force $tmpDir }
  return
}
# erzeugte Testseiten-Dateien (u. a. Passwort-Hash) auch bei Abbruch nicht liegen lassen
trap { if ($tmpDir) { Remove-Item -Recurse -Force $tmpDir -ErrorAction SilentlyContinue }; break }

if ($files.Count -eq 0) { Write-Host "Nichts hochzuladen." }
elseif ($proto -eq "ftps") {
  # FTPS: TLS ist Pflicht (--ssl-reqd) – ohne Verschlüsselung bricht der Upload ab.
  # --tls-max 1.2: Mit TLS 1.3 bricht die Datenverbindung zwischen Windows (Schannel) und dem
  # ALL-INKL-Server ab (Fehler 426, Datei kommt mit 0 Byte an). TLS 1.2 ist weiterhin sicher.
  $basis = "ftp://$($cfg.FTP_HOST)$remoteDir/"

  # Erst alle Dateien in einem einzigen curl-Aufruf: Die Verbindung bleibt offen, statt für jede
  # Datei neu aufgebaut und angemeldet zu werden. Die Dateiliste steht in einer curl-Konfigdatei.
  $liste = New-TemporaryFile
  $zeilen = for ($i = 0; $i -lt $files.Count; $i++) {
    "upload-file = `"$($files[$i].FullName.Replace('\', '/'))`""
    "url = `"$basis$($rels[$i])`""
  }
  [IO.File]::WriteAllLines($liste.FullName, [string[]]$zeilen, $utf8)
  $angekommen = @{}
  try {
    & curl.exe --silent --show-error --ssl-reqd --tls-max 1.2 --ftp-create-dirs `
      --user "$($cfg.FTP_USER):$($cfg.FTP_PASS)" -K $liste.FullName -w "%{exitcode} %{url}\n" | ForEach-Object {
      if ($_ -match '^0 (.+)$') { $angekommen[$Matches[1]] = $true; Write-Host "  $($Matches[1].Substring($basis.Length))" }
    }
  }
  finally { Remove-Item $liste -Force }

  # Was dabei nicht geklappt hat, einzeln nachladen
  $nachladen = @(for ($i = 0; $i -lt $files.Count; $i++) { if (-not $angekommen.ContainsKey("$basis$($rels[$i])")) { $i } })
  if ($nachladen) { Write-Host "$($nachladen.Count) Datei(en) einzeln nachladen …" }
  foreach ($i in $nachladen) {
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
  for ($i = 0; $i -lt $files.Count; $i++) { $batch += "put `"$($files[$i].FullName.Replace('\', '/'))`" `"$ziel/$($rels[$i])`"" }
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
if ($tmpDir) { Remove-Item -Recurse -Force $tmpDir }

# Markierung auf den hochgeladenen Commit setzen (nicht bei nicht committeten Änderungen)
if (-not $offen) {
  & git -C $root tag -f $marke HEAD | Out-Null
  Write-Host "Markierung '$marke' -> $(& git -C $root rev-parse --short HEAD)"
}
Write-Host "Fertig."
