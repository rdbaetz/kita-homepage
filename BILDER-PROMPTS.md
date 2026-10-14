# Bild-Prompts für ChatGPT

**Automatisch (empfohlen):** `python tools/bilder_generieren.py` im Projektordner ausführen. Das Skript nutzt die Codex CLI mit dem ChatGPT-Plus-Login (keine API-Kosten) und speichert die Bilder direkt am richtigen Ort. Einzelne Bilder: `python tools/bilder_generieren.py hero`, neu erzeugen mit `--neu`.

**Manuell** in der ChatGPT-App:

1. In ChatGPT zuerst den **Stil-Block** einfügen, danach jeweils einen Bild-Prompt (alle Bilder im selben Chat erzeugen, damit der Stil einheitlich bleibt).
2. Bild als PNG herunterladen (ein mitgemaltes Karomuster statt echter Transparenz ist okay).
3. Unter dem angegebenen Dateinamen in **`bilder-roh/`** speichern (Ordner ist nicht in Git).
4. `python tools/bilder_aufbereiten.py` ausführen – oder Claude Code Bescheid sagen. Das Skript entfernt das Karomuster, verkleinert und speichert als WebP in `assets/img/illustrations/`.

Solange ein Bild fehlt, zeigt die Seite automatisch eine schlichte Ersatzgrafik.

---

## Stil-Block (immer zuerst)

```
Für alle folgenden Bilder gilt dieser Stil:
Sanfte, kindgerechte Bilderbuch-Illustration im Aquarell-/Gouache-Look, flache Formen mit feiner Papier-Textur, keine harten Konturen.
Farbpalette: Salbeigrün (#6e9e78, #8db58a, #c9dfb4), Cremeweiß (#f8f6ee), warmes Sonnengelb (#f2c230), zarte Pastelltöne (Pfirsich, Hellblau). Kleine Akzente in Rot und Kobaltblau sind erlaubt.
Kinder mit runden Gesichtern, rosigen Wangen, fröhlichem Ausdruck, vielfältig (verschiedene Haarfarben/Hauttöne), Kleidung in gedeckten Pastellfarben.
Kein Text, keine Buchstaben, keine Logos, keine Wasserzeichen.
Transparenter Hintergrund (PNG), Motiv freigestellt.
```

---

## 1. Hero – `hero.png`
Format: Querformat ca. 6:5 (z. B. 1536×1280)

```
Ländliche Hügellandschaft im Frankenwald: Auf einem sanften grünen Hügel steht ein kleiner, freundlicher Kindergarten (weißes Haus mit grünem Satteldach, runde Holztür, kleines Herz im Giebel, daneben ein schlichter kleiner Kirchturm im Hintergrund).
Im Vordergrund rennen drei fröhliche Kinder (ca. 4–5 Jahre) mit ausgebreiteten Armen über die Wiese, eines lässt einen kleinen Drachen steigen.
Oben links eine lachende, stilisierte Sonne, ein paar weiche Wolken, runde Laubbäume und Tannen links und rechts, weiße Gänseblümchen im Gras.
Der untere Rand läuft als weiche, wellige Wiese aus. Transparenter Hintergrund außerhalb der Szene.
```

### Hero, Variante 2 – `hero-2.png`
Format: Querformat ca. 6:5 (z. B. 1536×1280)

Passend zum Slogan „Gemeinsam lernen, entdecken und wachsen“ und zum Leitspruch „Man ist nie zu klein, um großartig zu sein“. Die Sonne wird per `tools/hero_ebenen.py` als eigene Ebene animiert – deshalb muss sie frei stehen.

```
Der Garten eines kleinen, freundlichen Kindergartens im Frankenwald: Im Hintergrund das Kita-Haus (weißes Haus mit grünem Satteldach, runde Holztür, kleines Herz im Giebel), dahinter angedeutet ein schlichter kleiner Kirchturm, ein paar runde Laubbäume und Tannen, ein niedriger Holzzaun.
Im Vordergrund links ein Sandkasten mit Holzrand: Zwei Kinder (ca. 4 Jahre) bauen zusammen eine Sandburg, eine freundliche Erzieherin (ca. 35 Jahre, Pastellkleidung, Haare zum Dutt) kniet am Rand des Sandkastens und schaut ihnen lächelnd zu.
Rechts eine kleine Holzrutsche mit Leiter: Ein größeres Kind (ca. 6 Jahre) hilft einem ganz kleinen Kind (ca. 3 Jahre) die Leiter hinauf, das Kleine strahlt stolz.
In der Mitte vorne hockt ein Kind im Gras und betrachtet mit einer Lupe einen Marienkäfer auf einem Gänseblümchen.
Kinder vielfältig, alle fröhlich, niemand schaut den Betrachter direkt an. Ruhige, übersichtliche Komposition mit klaren Gruppen und Luft dazwischen, nicht überladen.
Oben links eine große lachende, stilisierte Sonne mit rundem Gesicht und einzelnen, getrennt stehenden Strahlen. Die Sonne steht frei im Himmel und berührt weder Bäume, Wolken noch das Haus (deutlicher Abstand rundherum). Ein bis zwei weiche Wolken nur rechts oben.
Weiße Gänseblümchen im Gras. Der untere Rand läuft als weiche, wellige Wiese aus. Transparenter Hintergrund außerhalb der Szene.
```

### Hero, Variante 3 – `hero-3.png` (aktuell im Einsatz)
Format: Querformat ca. 6:5 (z. B. 1536×1280)

Wie Variante 2, aber mit dem echten Kita-Haus und Garten (nach Fotos vom 12.10.2026). Im ersten Versuch wurde das Bild zu kräftig und comicartig – deshalb der Zusatz zur Weichheit am Ende. Ebenen: `python tools/hero_ebenen.py hero-3`.

```
Der große, grüne Garten eines Kindergartens im Frankenwald, von einem leicht erhöhten Standpunkt gesehen.
Links im Hintergrund das Kita-Haus, leicht schräg von der Seite: ein langgestreckter, eingeschossiger Flachbau mit hellgelb-cremefarben verputzter Fassade und flach geneigtem, dunkelgrauem Walmdach mit grauer Dachrinne und niedrigem dunklem Schneefanggitter. Große Fenster mit dunkelgrauen Rahmen, auf deren Scheiben bunte Kinderbilder gemalt sind (Regenbogen, Herz, Luftballons – ohne Schrift), ein schmaler roter Wandabschnitt am Hausende, davor zwei bunte Drahtfiguren in Kindergestalt (rot und blau).
Rechts im Mittelgrund ein hölzerner Spielturm wie eine kleine Ritterburg: Turm mit spitzem grauem Dach und kleinem roten Fähnchen, eine Kletterwand mit bunten Griffen und eine silberne Rutsche. Ein größeres Kind (ca. 6 Jahre) hilft einem ganz kleinen Kind (ca. 3 Jahre) an der Kletterwand hinauf, das Kleine strahlt stolz.
Links im Vordergrund ein runder Sandplatz mit Holzrand, daneben ein Holzpferd und eine grüne Handschwengelpumpe. Im Sand bauen zwei Kinder (ca. 4 Jahre) zusammen eine Sandburg, eine freundliche Erzieherin (ca. 35 Jahre, Pastellkleidung, Haare zum Dutt) kniet am Rand und schaut ihnen lächelnd zu.
In der Mitte vorne hockt ein Kind im Gras und betrachtet mit einer Lupe einen Marienkäfer auf einem Gänseblümchen.
Ein geschwungener, hellgrauer Pflasterweg führt durch die Wiese. Am Wegrand ein Holz-Picknicktisch mit roten Beinen und ein paar bunt bemalte, schlanke Holzstangen. Ein großer Kastanienbaum mit rosa Blütenkerzen rahmt die Szene rechts, ein weißes Sonnensegel spannt sich über einen Teil des Spielplatzes.
Niemand schaut den Betrachter direkt an. Ruhige, übersichtliche Komposition mit klaren Gruppen und Luft dazwischen, nicht überladen.
Oben links eine große lachende, stilisierte Sonne mit rundem Gesicht und einzelnen, getrennt stehenden Strahlen. Die Sonne steht frei im Himmel und berührt weder Bäume, Wolken noch das Haus (deutlicher Abstand rundherum). Ein bis zwei weiche Wolken nur rechts oben.
Weiße Gänseblümchen im Gras. Der untere Rand läuft als weiche, wellige Wiese aus. Transparenter Hintergrund außerhalb der Szene.
Sehr weiche, blasse Aquarellfarben, keine Konturlinien, gedeckte Sättigung, viel Luft, alle Ränder weich auslaufend.
```

### Hero, Variante 3 im Winter – `hero-3-winter.png` (im Winter 21.12.–19.3. im Einsatz)
Format: wie die Vorlage (1374×1145)

Erzeugt per Bild-zu-Bild: Codex bekommt `bilder-roh/hero-3.png` als Vorlage angehängt (`codex exec … -i bilder-roh/hero-3.png`, nicht über `tools/bilder_generieren.py`, das nur Text kann). Danach `python tools/hero_ebenen.py hero-3-winter` und die Positionen ins CSS (`[data-jahreszeit="winter"] .hero-szene`).

```
Das angehängte Bild ist die Vorlage. Erzeuge DIESELBE Szene als Winterversion: gleicher Bildausschnitt, gleiche Perspektive, gleiche Anordnung und Größe aller Gebäude, Geräte, Personen und Bäume, gleicher Malstil (sehr weiche, blasse Aquarellfarben, keine Konturlinien, weich auslaufende Ränder). Nur die Jahreszeit ändert sich:

- Eine dünne, weiche Schneedecke liegt auf Wiese, Weg, Dach des Hauses, Turmdach, Picknicktisch, Holzrand des Sandplatzes und Holzpferd. Das Gras schaut stellenweise noch durch. Keine Gänseblümchen.
- Alle Personen tragen warme Winterkleidung in gedeckten Pastellfarben: gefütterte Jacken, Strickmützen mit Bommel, Schals, Fäustlinge, lange Hosen, Winterstiefel. Die Erzieherin trägt Mantel, Mütze und Schal.
- Die zwei Kinder links bauen statt der Sandburg einen kleinen Schneemann auf dem verschneiten Sandplatz.
- Das Kind vorne in der Mitte betrachtet mit der Lupe eine Schneeflocke auf seinem Fäustling (statt Marienkäfer und Blume).
- Die Kinder am Spielturm bleiben wie sie sind, nur winterlich angezogen.
- Der Kastanienbaum rechts ist kahl (keine Blätter, keine Blüten), mit etwas Schnee auf den Ästen. Die Laubbüsche werden zu schneebedeckten, blattlosen Sträuchern; die Nadelbäume im Hintergrund bleiben grün mit Schnee.
- Kein Sonnensegel (im Winter abgebaut), die Holzpfosten bleiben.
- Die lachende Sonne oben links bleibt EXAKT an derselben Stelle, in derselben Größe und Form wie in der Vorlage, frei im Himmel. Die zwei Wolken rechts oben bleiben.
- Himmel und Hintergrund außerhalb der Szene bleiben transparent bzw. weiß wie in der Vorlage, der untere Rand läuft als weiche, wellige verschneite Wiese aus.

Niemand schaut den Betrachter an. Kein Text, keine Buchstaben, keine Logos.
```

## 2. Über uns – `ueber-uns.png`
Format: Querformat ca. 6:5

```
Ein kleines Mädchen (ca. 4 Jahre, braune Haare, gelber Pullover, Blume im Haar) sitzt im Schneidersitz auf einer runden Wiesen-Insel und liest vergnügt in einem großen grünen Bilderbuch.
Neben ihr sitzt ein weißes Häschen und schaut neugierig ins Buch. Ein gelber Schmetterling fliegt mit einer gepunkteten Flugbahn über ihnen.
Rechts ein runder Laubbaum, Gräser und weiße Blumen am Rand. Ruhige, geborgene Stimmung. Transparenter Hintergrund.
```

### Über uns, Variante 2 – `ueber-uns-2.png`
Format: Querformat ca. 6:5 (z. B. 1536×1280)

Passend zum Text „Was uns wichtig ist“ (Respekt, Geborgenheit, Wertschätzung, Gemeinschaft, verlässliche Beziehung).

```
Eine freundliche Erzieherin (ca. 35 Jahre, Pastellkleidung) sitzt auf einer runden Wiesen-Insel unter einem großen, schützenden Laubbaum, dessen Krone sich wie ein Dach über die Gruppe wölbt.
Ein kleines Kind (ca. 3 Jahre) kuschelt sich vertrauensvoll an ihre Seite, sie legt ihm sanft den Arm um die Schulter.
Daneben sitzen drei weitere Kinder (ca. 4–6 Jahre, vielfältig) im Halbkreis auf der Wiese: zwei halten sich an den Händen, eines reicht einem anderen eine Blume.
Alle schauen sich freundlich an, niemand schaut den Betrachter direkt an. Gräser und weiße Blumen am Rand, ein gelber Schmetterling.
Ruhige, warme, geborgene Stimmung, viel Luft rundherum. Transparenter Hintergrund.
```

## 3. Angebote (je quadratisch 1024×1024, Motiv mittig, viel Luft rundherum)

### `angebot-bildung.png`
```
Einzelnes Icon-Motiv: Eine Malerpalette mit bunten Farbklecksen, ein Pinsel und ein kleines Holzpuzzle-Teil. Kein Hintergrund, quadratisch, Motiv zentriert.
```

### `angebot-vorschule.png`
```
Einzelnes Icon-Motiv: Ein kleiner grüner Schulranzen mit gelber Schnalle, daneben zwei Buntstifte und ein Lineal. Kein Hintergrund, quadratisch, Motiv zentriert.
```

### `angebot-schwimmen.png`
```
Einzelnes Icon-Motiv: Ein rot-weißer Schwimmring und eine kleine gelbe Badeente auf sanften hellblauen Wellen. Kein Hintergrund, quadratisch, Motiv zentriert.
```

### `angebot-englisch.png`
```
Einzelnes Icon-Motiv: Zwei bunte Sprechblasen (eine grün, eine gelb) ohne Text, daneben ein kleiner roter Doppeldeckerbus als Spielzeug. Kein Hintergrund, quadratisch, Motiv zentriert.
```

### `angebot-feste.png`
```
Einzelnes Icon-Motiv: Eine leuchtende Laterne (St.-Martins-Laterne) in Gelb und Orange, daneben ein kleiner goldener Stern und ein Tannenzweig. Kein Hintergrund, quadratisch, Motiv zentriert.
```

### `angebot-draussen.png`
```
Einzelnes Icon-Motiv: Ein kleiner Setzling mit zwei grünen Blättern in einem Erdhügel, daneben eine rote Kinder-Schaufel und ein Marienkäfer. Kein Hintergrund, quadratisch, Motiv zentriert.
```

## 4. Gruppen (je quadratisch 1024×1024)

### `gruppe-perlen.png`
```
Einzelnes Icon-Motiv: Eine geöffnete, hellblau-rosa schimmernde Muschel mit einer großen glänzenden weißen Perle darin, liebevoll und weich. Kein Hintergrund, quadratisch, Motiv zentriert.
```

### `gruppe-edelsteine.png`
```
Einzelnes Icon-Motiv: Drei funkelnde, facettierte Edelsteine (rosa, grün, hellblau) in einem kleinen Häufchen, kindlich-verspielt mit kleinen Glitzer-Sternchen. Kein Hintergrund, quadratisch, Motiv zentriert.
```

### `gruppe-goldtaler.png`
```
Einzelnes Icon-Motiv: Ein kleiner Stapel glänzender Goldtaler, ein Taler steht aufrecht und hat einen Stern eingeprägt, kleine Glitzer-Sternchen drumherum. Keine Zahlen, keine Schrift. Kein Hintergrund, quadratisch, Motiv zentriert.
```
