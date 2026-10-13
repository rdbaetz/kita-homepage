# Erzeugt die Seite "aenderungen.html" für die Testseite: die letzten Commits mit Datum, Beschreibung
# und geänderten Dateien. Was noch nicht live ist (Markierung "live"), wird hervorgehoben.
#
# Wird von "deploy.ps1 -Dev" aufgerufen. Lokal ansehen:
#   powershell -ExecutionPolicy Bypass -File .\tools\aenderungen.ps1 -Ziel aenderungen.html

param([string]$Ziel, [int]$Anzahl = 100, [string[]]$NichtCommittet = @())

$root = Split-Path $PSScriptRoot -Parent
$alt = [Console]::OutputEncoding
[Console]::OutputEncoding = [Text.Encoding]::UTF8
try {
  function E([string]$s) { $s.Replace("&", "&amp;").Replace("<", "&lt;").Replace(">", "&gt;").Replace('"', "&quot;") }

  $nichtLive = @{}
  if (& git -C $root rev-parse --verify --quiet "live^{commit}") {
    & git -C $root rev-list "live..HEAD" | ForEach-Object { $nichtLive[$_] = $true }
  }

  $roh = (& git -C $root -c core.quotepath=off log -n $Anzahl --date=format:"%d.%m.%Y, %H:%M Uhr" `
      --format="%x1e%H%x1f%h%x1f%ad%x1f%s%x1f%b%x1f" --name-status --no-renames) -join "`n"

  $eintraege = foreach ($rec in ($roh -split "\x1e" | Where-Object { $_.Trim() })) {
    $f = $rec -split "\x1f"
    # Trailer wie "Co-Authored-By:" gehören nicht in die Beschreibung
    $text = (($f[4] -split "`n") | Where-Object { $_ -notmatch '^\s*[A-Za-z-]+-By:' }) -join "`n"
    $absaetze = ($text.Trim() -split "\n\s*\n" | Where-Object { $_.Trim() } | ForEach-Object {
        $zeilen = $_.Trim() -split "`n"
        if (@($zeilen | Where-Object { $_ -notmatch '^\s*-\s' }).Count -eq 0) {
          "<ul>" + (($zeilen | ForEach-Object { "<li>" + (E ($_ -replace '^\s*-\s*', '')) + "</li>" }) -join "") + "</ul>"
        }
        else {
          # eingerückte Fortsetzungszeilen von Aufzählungen zusammenziehen
          "<p>" + ((E ($_.Trim() -replace "\n\s+", " ")) -replace "`n", "<br>") + "</p>"
        }
      }) -join "`n"
    $dateien = ($f[5] -split "`n" | Where-Object { $_ -match "^([AMD])\t(.+)$" } | ForEach-Object {
        $art = @{ A = "neu"; M = "geändert"; D = "gelöscht" }[$Matches[1]]
        "<li><span class=`"art art-$($Matches[1])`">$art</span> <code>$(E $Matches[2])</code></li>"
      }) -join ""
    $neu = $nichtLive.ContainsKey($f[0])
    @"
<article class="commit$(if ($neu) { ' neu' })">
  <header><h2>$(E $f[3])</h2>$(if ($neu) { '<span class="badge">noch nicht live</span>' })</header>
  <p class="meta">$(E $f[2]) · <code>$($f[1])</code></p>
  $absaetze
  $(if ($dateien) { "<details><summary>Dateien</summary><ul class=`"dateien`">$dateien</ul></details>" })
</article>
"@
  }

  $offen = if ($NichtCommittet) {
    $liste = ($NichtCommittet | ForEach-Object { "<li><code>$(E $_)</code></li>" }) -join ""
    "<article class=`"commit neu`"><header><h2>Noch nicht committet</h2><span class=`"badge`">noch nicht live</span></header><p>Diese Änderungen sind auf der Testseite, aber noch in keinem Commit:</p><ul class=`"dateien`">$liste</ul></article>"
  }

  $stand = Get-Date -Format "dd.MM.yyyy, HH:mm 'Uhr'"
  $html = @"
<!doctype html>
<html lang="de">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta name="robots" content="noindex, nofollow">
<title>Änderungen – Testseite Kita Neufang</title>
<link rel="stylesheet" href="assets/css/style.css">
<style>
  body { background: var(--cream); }
  .aend { max-width: 760px; margin: 0 auto; padding: 32px 16px 64px; }
  .aend > p { color: var(--ink-soft); }
  .commit { background: #fff; border-radius: var(--radius); box-shadow: var(--shadow); padding: 18px 20px; margin-top: 16px; }
  .commit.neu { outline: 3px solid var(--green-600); }
  .commit header { display: flex; flex-wrap: wrap; gap: 8px 12px; align-items: baseline; }
  .commit h2 { font-size: 1.2rem; margin: 0; }
  .commit p, .commit ul { margin: 8px 0 0; }
  .commit ul { padding-left: 1.2em; }
  .meta { color: var(--muted); font-size: 0.9rem; }
  .badge { background: var(--green-600); color: #fff; border-radius: 99px; padding: 2px 10px; font-size: 0.8rem; font-weight: 700; }
  details { margin-top: 8px; font-size: 0.9rem; }
  summary { cursor: pointer; color: var(--muted); font-weight: 700; }
  .dateien { list-style: none; padding: 0 !important; }
  .dateien code { word-break: break-all; }
  .art { display: inline-block; min-width: 5.5em; font-weight: 700; }
  .art-A { color: #2f7a3d; } .art-D { color: #b23a2a; } .art-M { color: var(--muted); }
</style>
</head>
<body>
<main class="aend">
  <p><a href="./">← Zur Testseite</a></p>
  <h1>Änderungen</h1>
  <p>Die letzten Änderungen an der Website, neueste zuerst. Grün umrandet: auf der Testseite, aber noch nicht live. Stand: $stand</p>
  $offen
  $($eintraege -join "`n")
</main>
</body>
</html>
"@
}
finally { [Console]::OutputEncoding = $alt }

if ($Ziel) { [IO.File]::WriteAllText($Ziel, $html, (New-Object Text.UTF8Encoding($false))) } else { $html }
