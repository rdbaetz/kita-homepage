# Erzeugt die Seite "aenderungen.html" für die Testseite: die letzten Commits mit Datum, Beschreibung
# und geänderten Dateien. Was noch nicht live ist (Markierung "live"), wird hervorgehoben.
#
# Wird von "deploy.ps1 -Dev" aufgerufen. Lokal ansehen:
#   powershell -ExecutionPolicy Bypass -File .\tools\aenderungen.ps1 -Ziel aenderungen.html

param([string]$Ziel, [int]$Anzahl = 500, [string[]]$NichtCommittet = @())

$root = Split-Path $PSScriptRoot -Parent
$alt = [Console]::OutputEncoding
[Console]::OutputEncoding = [Text.Encoding]::UTF8
try {
  function E([string]$s) { $s.Replace("&", "&amp;").Replace("<", "&lt;").Replace(">", "&gt;").Replace('"', "&quot;") }

  $nichtLive = @{}
  if (& git -C $root rev-parse --verify --quiet "live^{commit}") {
    & git -C $root rev-list "live..HEAD" | ForEach-Object { $nichtLive[$_] = $true }
  }

  $roh = (& git -C $root -c core.quotepath=off log -n $Anzahl --date=format:"%d.%m.%y %H:%M" `
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
      }) -join ""
    $dateien = ($f[5] -split "`n" | Where-Object { $_ -match "^([AMD])\t(.+)$" } | ForEach-Object {
        $art = @{ A = "neu"; M = "geändert"; D = "gelöscht" }[$Matches[1]]
        "<li><span class=`"art art-$($Matches[1])`">$art</span> <code>$(E $Matches[2])</code></li>"
      }) -join ""
    $neu = $nichtLive.ContainsKey($f[0])
    $klasse = if ($neu) { "c neu" } else { "c" }
    $badge = if ($neu) { '<span class="badge">nicht live</span>' } else { "" }
    if ($dateien) { $dateien = '<ul class="dateien">' + $dateien + '</ul>' }
    '<details class="' + $klasse + '"><summary><time>' + $f[2] + '</time><span class="t">' + (E $f[3]) + '</span>' + $badge +
    '</summary><div class="inhalt">' + $absaetze + $dateien + '<p class="meta">Commit <code>' + $f[1] + '</code></p></div></details>'
  }

  $offen = if ($NichtCommittet) {
    $liste = ($NichtCommittet | ForEach-Object { "<li><code>$(E $_)</code></li>" }) -join ""
    '<details class="c neu" open><summary><time>jetzt</time><span class="t">Noch nicht committet</span><span class="badge">nicht live</span></summary>' +
    '<div class="inhalt"><p>Auf der Testseite, aber noch in keinem Commit:</p><ul class="dateien">' + $liste + '</ul></div></details>'
  }

  $offenBlock = if ($offen) { '<div class="liste" style="margin-bottom:12px">' + $offen + '</div>' } else { "" }
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
  .aend { max-width: 820px; margin: 0 auto; padding: 24px 16px 48px; }
  .aend h1 { font-size: 1.8rem; margin: 4px 0; }
  .hinweis { color: var(--ink-soft); font-size: 0.9rem; margin: 0 0 12px; }
  .leiste { display: flex; flex-wrap: wrap; gap: 8px 16px; align-items: center; justify-content: space-between; margin: 12px 0 8px; font-size: 0.9rem; }
  .leiste select, .leiste button { font: inherit; padding: 4px 10px; border-radius: 8px; border: 1px solid #cfd8cc; background: #fff; color: var(--ink); }
  .leiste button:disabled { opacity: 0.4; }
  .blaettern { display: flex; gap: 6px; align-items: center; }
  .liste { background: #fff; border-radius: 12px; box-shadow: var(--shadow); overflow: hidden; }
  .c + .c { border-top: 1px solid #eceee8; }
  .c summary { display: flex; gap: 12px; align-items: baseline; padding: 8px 14px; cursor: pointer; list-style: none; font-size: 0.95rem; }
  .c summary::-webkit-details-marker { display: none; }
  .c summary:hover { background: #f6f8f3; }
  .c time { flex: none; width: 7.6em; color: var(--muted); font-variant-numeric: tabular-nums; font-size: 0.85rem; }
  .c .t { flex: 1; font-weight: 700; }
  .c.neu { box-shadow: inset 4px 0 0 var(--green-600); }
  .badge { flex: none; background: var(--green-600); color: #fff; border-radius: 99px; padding: 1px 8px; font-size: 0.75rem; font-weight: 700; }
  .inhalt { padding: 0 14px 10px calc(14px + 7.6em + 12px); font-size: 0.9rem; color: var(--ink-soft); }
  .inhalt p, .inhalt ul { margin: 4px 0 0; }
  .inhalt ul { padding-left: 1.2em; }
  .dateien { list-style: none; padding: 0 !important; font-size: 0.85rem; }
  .dateien code, .meta code { word-break: break-all; }
  .meta { color: var(--muted); font-size: 0.8rem; }
  .art { display: inline-block; min-width: 5.5em; font-weight: 700; }
  .art-A { color: #2f7a3d; } .art-D { color: #b23a2a; } .art-M { color: var(--muted); }
  @media (max-width: 560px) {
    .c summary { flex-wrap: wrap; gap: 2px 10px; }
    .c time { width: auto; }
    .c .t { flex-basis: 100%; order: 3; }
    .inhalt { padding-left: 14px; }
  }
</style>
</head>
<body>
<main class="aend">
  <p><a href="./">← Zur Testseite</a></p>
  <h1>Änderungen</h1>
  <p class="hinweis">Neueste zuerst, zum Aufklappen anklicken. Grün markiert: auf der Testseite, aber noch nicht live. Stand: $stand</p>
  $offenBlock
  <div class="leiste">
    <label>Pro Seite <select id="proSeite"><option>10</option><option selected>25</option><option>50</option><option value="0">alle</option></select></label>
    <div class="blaettern"><button id="zurueck" aria-label="Vorherige Seite">‹</button><span id="anzeige" aria-live="polite"></span><button id="weiter" aria-label="Nächste Seite">›</button></div>
  </div>
  <div class="liste" id="liste">
  $($eintraege -join "`n")
  </div>
</main>
<script>
(() => {
  const eintraege = [...document.querySelectorAll("#liste > .c")];
  const wahl = document.getElementById("proSeite");
  const anzeige = document.getElementById("anzeige");
  const zurueck = document.getElementById("zurueck");
  const weiter = document.getElementById("weiter");
  let seite = 0;
  try { const g = localStorage.getItem("aend-pro-seite"); if (g !== null && [...wahl.options].some((o) => o.value === g)) wahl.value = g; } catch (e) {}
  const zeigen = () => {
    const pro = +wahl.value || eintraege.length || 1;
    const seiten = Math.max(1, Math.ceil(eintraege.length / pro));
    seite = Math.min(Math.max(seite, 0), seiten - 1);
    const von = seite * pro, bis = Math.min(von + pro, eintraege.length);
    eintraege.forEach((el, i) => { el.hidden = i < von || i >= bis; });
    anzeige.textContent = eintraege.length ? (von + 1) + "–" + bis + " von " + eintraege.length : "keine";
    zurueck.disabled = seite === 0;
    weiter.disabled = seite >= seiten - 1;
  };
  wahl.addEventListener("change", () => { seite = 0; try { localStorage.setItem("aend-pro-seite", wahl.value); } catch (e) {} zeigen(); });
  zurueck.addEventListener("click", () => { seite--; zeigen(); });
  weiter.addEventListener("click", () => { seite++; zeigen(); });
  zeigen();
})();
</script>
</body>
</html>
"@
}
finally { [Console]::OutputEncoding = $alt }

if ($Ziel) { [IO.File]::WriteAllText($Ziel, $html, (New-Object Text.UTF8Encoding($false))) } else { $html }
