// Kita St. Laurentius Neufang – kleine Helfer (kein Framework nötig)

// E-Mail-Schutz: Die Adresse steht im HTML rückwärts und mit "#" statt "@" (data-m)
// und wird erst hier zu einem klickbaren Link zusammengesetzt.
document.querySelectorAll(".js-mail[data-m]").forEach((a) => {
  const adresse = a.dataset.m.split("").reverse().join("").replace("#", "@");
  a.href = "mailto:" + adresse;
  a.textContent = adresse;
});

// Mobiles Menü
const toggle = document.querySelector(".nav-toggle");
const nav = document.getElementById("main-nav");
if (toggle && nav) {
  toggle.addEventListener("click", () => {
    const open = nav.classList.toggle("open");
    toggle.setAttribute("aria-expanded", open);
    toggle.setAttribute("aria-label", open ? "Menü schließen" : "Menü öffnen");
  });
  nav.addEventListener("click", (e) => {
    if (e.target.closest("a")) {
      nav.classList.remove("open");
      toggle.setAttribute("aria-expanded", "false");
    }
  });
}

// Header-Logo einblenden, sobald das große Logo im Hero aus dem Bild scrollt
const heroLogo = document.querySelector(".hero-logo");
const headerEl = document.querySelector(".site-header");
if (heroLogo && headerEl && "IntersectionObserver" in window) {
  document.documentElement.classList.add("js-logo");
  new IntersectionObserver(
    ([entry]) => headerEl.classList.toggle("brand-sichtbar", !entry.isIntersecting),
    { rootMargin: "-80px 0px 0px 0px" }
  ).observe(heroLogo);
}

// Schatten unter dem Header beim Scrollen
const header = document.querySelector(".site-header");
const onScroll = () => header && header.classList.toggle("scrolled", window.scrollY > 8);
window.addEventListener("scroll", onScroll, { passive: true });
onScroll();

// Aktiven Menüpunkt markieren: der letzte Abschnitt, dessen Anfang schon oben angekommen ist
// (Grenze höchstens 300 px unter dem Fensterrand – sonst würde auf hohen Bildschirmen ein kurzer
// Abschnitt wie „Unser Haus“ gleich vom nächsten abgelöst). Ganz unten: der letzte Abschnitt.
const links = [...document.querySelectorAll('.main-nav a[href^="#"]')];
const ziele = links.map((a) => document.querySelector(a.getAttribute("href"))).filter(Boolean);
// nur äußere Abschnitte (#voranmeldung liegt in #kontakt), in Seitenreihenfolge
const sections = ziele.filter((s) => !ziele.some((t) => t !== s && t.contains(s)));
let aktiv = null;
function markiereMenue() {
  const grenze = Math.min(window.innerHeight * 0.4, 300);
  let neu = null;
  sections.forEach((s) => {
    if (s.getBoundingClientRect().top <= grenze) neu = s;
  });
  if (window.innerHeight + window.scrollY >= document.documentElement.scrollHeight - 2) neu = sections[sections.length - 1];
  if (neu === aktiv) return;
  aktiv = neu;
  links.forEach((a) => a.classList.toggle("active", !!neu && a.getAttribute("href") === "#" + neu.id));
}
if (sections.length) {
  let geplant = false;
  const planen = () => {
    if (geplant) return;
    geplant = true;
    requestAnimationFrame(() => {
      geplant = false;
      markiereMenue();
    });
  };
  window.addEventListener("scroll", planen, { passive: true });
  window.addEventListener("resize", planen);
  markiereMenue();
}

// Angebote: Detail-Dialoge
document.querySelectorAll("[data-dialog]").forEach((btn) => {
  const dlg = document.getElementById(btn.dataset.dialog);
  if (!dlg || typeof dlg.showModal !== "function") return;
  btn.addEventListener("click", () => {
    // Bild der Kachel (oder deren Ersatzgrafik) in den farbigen Kreis im Dialog-Kopf übernehmen
    const dot = dlg.querySelector(".info-head .dot");
    if (dot && !dot.firstElementChild) {
      const bild = btn.querySelector(".circle img.ill") || btn.querySelector(".circle .fallback");
      if (bild) dot.append(bild.cloneNode(true));
    }
    dlg.showModal();
  });
});
document.querySelectorAll("dialog.info").forEach((dlg) => {
  dlg.querySelector(".close")?.addEventListener("click", () => dlg.close());
  // Klick auf den abgedunkelten Hintergrund schließt den Dialog
  dlg.addEventListener("click", (e) => {
    if (e.target === dlg) dlg.close();
  });
});

// Team nach Gruppe filtern
const chips = document.querySelectorAll(".team-filter .chip");
chips.forEach((chip) => {
  chip.addEventListener("click", () => {
    const f = chip.dataset.filter;
    chips.forEach((c) => {
      c.classList.toggle("active", c === chip);
      c.setAttribute("aria-pressed", c === chip);
    });
    document.querySelector(".team-grid")?.classList.add("gefiltert");
    document.querySelectorAll(".member[data-gruppen]").forEach((m) => {
      m.classList.toggle("hidden", f !== "alle" && !m.dataset.gruppen.split(" ").includes(f));
    });
  });
});

// Vergangene Schließtage ausgrauen
const today = new Date();
today.setHours(0, 0, 0, 0);
document.querySelectorAll("[data-ende]").forEach((li) => {
  const end = new Date(li.dataset.ende + "T00:00:00");
  if (end < today) li.classList.add("past");
});

// Mitarbeiterzahl automatisch aus dem Team-Abschnitt
const anzahl = document.querySelectorAll(".team-grid .member").length;
document.querySelectorAll("[data-team-anzahl]").forEach((el) => anzahl && (el.textContent = anzahl));

// Jahr im Footer
document.querySelectorAll("[data-year]").forEach((el) => (el.textContent = new Date().getFullYear()));

// Sanftes Einblenden beim Scrollen – Elemente in Rastern erscheinen nacheinander
const reveals = document.querySelectorAll(".reveal");
document.querySelectorAll(".program-grid, .group-grid, .team-grid, .times-grid, .fee-grid, .stats, .signup-grid").forEach((grid) => {
  [...grid.children].forEach((el, i) => el.style.setProperty("--d", `${Math.min(i, 8) * 70}ms`));
});
if ("IntersectionObserver" in window) {
  const io = new IntersectionObserver(
    (entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          entry.target.classList.add("in");
          io.unobserve(entry.target);
        }
      });
    },
    { threshold: 0.12 }
  );
  reveals.forEach((el) => io.observe(el));
} else {
  reveals.forEach((el) => el.classList.add("in"));
}

// ---------------------------------------------------------------
// Bewegung (wird bei "Bewegung reduzieren" im System abgeschaltet)
// ---------------------------------------------------------------
const reduceMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches;

// "Nach oben"-Knopf
const topBtn = document.createElement("a");
topBtn.href = "#start";
topBtn.className = "to-top";
topBtn.setAttribute("aria-label", "Nach oben");
topBtn.innerHTML = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round"><path d="M12 19V5M6 11l6-6 6 6"/></svg>';
document.body.appendChild(topBtn);

// Entwürfe (hidden data-entwurf) nur mit ?entwurf an der Adresse zeigen, z. B. „Gut zu wissen“
if (new URLSearchParams(location.search).has("entwurf")) {
  document.querySelectorAll("[data-entwurf]").forEach((el) => (el.hidden = false));
}

// Hero: Jahreszeit – im Frühling fallen Blütenblätter, im Herbst Blätter, im Winter Schnee
// (Sommer: nur die Sonne). Die Jahreszeit bestimmt das kleine Skript hinter dem Titelbild in index.html
// (dort auch das Winterbild). Zum Testen: ?jahreszeit=fruehling|herbst|winter|sommer
const heroSzene = document.querySelector(".hero-szene");
if (heroSzene && !reduceMotion) {
  const jahreszeit = document.documentElement.dataset.jahreszeit;
  const formen = {
    // Blatt mit Mittelrippe, Farben: Orange, Rot, Gelb, Braun
    herbst: ["#e8892c", "#c9532e", "#e9b52f", "#a8642f"].map(
      (c) => `<svg viewBox="0 0 24 24"><path d="M12 2C6 7 4 13 6 18c1.5 3 4 4 6 4s4.5-1 6-4c2-5 0-11-6-16z" fill="${c}"/><path d="M12 6v16" stroke="rgba(80,40,10,.45)" stroke-width="1.2" fill="none"/></svg>`
    ),
    // Blütenblatt in Rosa (wie die Kastanienblüten im Bild)
    fruehling: ["#f6c6d3", "#f2b0c3", "#fbe0e7"].map(
      (c) => `<svg viewBox="0 0 24 24"><path d="M12 3c5 4 6 10 0 18C6 13 7 7 12 3z" fill="${c}"/></svg>`
    ),
    // Schneeflocke mit zartem Rand, damit sie auch vor hellem Himmel sichtbar ist
    winter: [`<svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="8.5" fill="#fff" stroke="#a9c3d6" stroke-width="3"/></svg>`],
  }[jahreszeit];
  if (formen) {
    const ebene = document.createElement("div");
    ebene.className = "jahreszeit " + jahreszeit;
    ebene.setAttribute("aria-hidden", "true");
    const anzahl = jahreszeit === "winter" ? 26 : 12;
    const zufall = (a, b) => a + Math.random() * (b - a);
    for (let i = 0; i < anzahl; i++) {
      const teil = document.createElement("i");
      // Fallen + kurz auf der Wiese liegen + verblassen (Aufteilung in style.css, jz-fallen)
      const dauer = zufall(13, 21);
      const x = zufall(2, 95);
      // Landehöhe auf der Wiese; an den Rändern läuft die Wiese früher ins Weiße aus
      const y = zufall(74, x < 8 || x > 88 ? 88 : 93);
      teil.style.cssText =
        `--x:${x.toFixed(1)}%;--y:${y.toFixed(1)}%;--s:${(jahreszeit === "winter" ? zufall(1.6, 2.8) : zufall(3, 5)).toFixed(2)}%;` +
        `--d:${dauer.toFixed(1)}s;--v:${(-zufall(0, dauer)).toFixed(1)}s;--p:${zufall(1.6, 3.2).toFixed(1)}s;` +
        `--w:${jahreszeit === "winter" ? 0 : zufall(10, 28).toFixed(0)}deg;--r:${zufall(-80, 80).toFixed(0)}deg`;
      teil.innerHTML = formen[i % formen.length];
      ebene.appendChild(teil);
    }
    heroSzene.appendChild(ebene);
    // außerhalb des Bildschirms anhalten (spart Akku)
    if ("IntersectionObserver" in window) {
      new IntersectionObserver(([e]) => ebene.classList.toggle("pause", !e.isIntersecting)).observe(heroSzene);
    }
  }
}

// Hero: leichte Tiefenwirkung beim Scrollen
const heroArt = document.querySelector(".hero-art");
const heroText = document.querySelector(".hero-text");

let ticking = false;
function onScrollFrame() {
  const y = window.scrollY;
  topBtn.classList.toggle("show", y > window.innerHeight * 0.8);
  if (!reduceMotion && y < window.innerHeight * 1.2) {
    if (heroArt) heroArt.style.transform = `translateY(${y * 0.12}px)`;
    if (heroText) heroText.style.transform = `translateY(${y * 0.05}px)`;
  }
  ticking = false;
}
window.addEventListener(
  "scroll",
  () => {
    if (!ticking) {
      ticking = true;
      requestAnimationFrame(onScrollFrame);
    }
  },
  { passive: true }
);
onScrollFrame();

// Zahlen hochzählen, sobald sie sichtbar werden
const counters = document.querySelectorAll(".stats strong");
if (!reduceMotion && "IntersectionObserver" in window) {
  const co = new IntersectionObserver(
    (entries) => {
      entries.forEach((entry) => {
        if (!entry.isIntersecting) return;
        co.unobserve(entry.target);
        const el = entry.target;
        const ziel = parseInt(el.textContent, 10);
        if (!ziel) return;
        const start = performance.now();
        const dauer = 1200;
        const step = (t) => {
          const p = Math.min(1, (t - start) / dauer);
          el.textContent = Math.round(ziel * (1 - Math.pow(1 - p, 3)));
          if (p < 1) requestAnimationFrame(step);
        };
        el.textContent = "0";
        requestAnimationFrame(step);
      });
    },
    { threshold: 0.6 }
  );
  counters.forEach((c) => co.observe(c));
}

// Gleitende Markierung im Menü (Desktop)
const navList = nav?.querySelector("ul");
const pill = document.createElement("span");
pill.className = "nav-pill";
pill.setAttribute("aria-hidden", "true");
navList?.prepend(pill);
function movePill() {
  const active = nav?.querySelector("li:not(.nav-cta) > a.active");
  if (!active || window.innerWidth <= 1060) {
    pill.style.opacity = "0";
    return;
  }
  const r = active.getBoundingClientRect();
  const pr = navList.getBoundingClientRect();
  pill.style.opacity = "1";
  pill.style.width = `${r.width}px`;
  pill.style.transform = `translateX(${r.left - pr.left}px)`;
}
if (nav) new MutationObserver(movePill).observe(nav, { subtree: true, attributes: true, attributeFilter: ["class"] });
window.addEventListener("resize", movePill);
document.fonts?.ready.then(movePill);

{
  // Fotos: Knopf mit data-raum (Gruppen-Karte, Kachel „Unser Haus“, Angebots-Dialog) → Vollbild-Galerie
  // mit Blättern, Tastatur und Wischen. Bilder je Bereich stehen im HTML in <template id="galerie-KEY"> als <figure>-Liste.

  // Kacheln nacheinander einblenden (wie die anderen Raster)
  document.querySelectorAll(".tour-grid > *").forEach((el, i) => el.style.setProperty("--d", `${Math.min(i, 8) * 70}ms`));

  const dlg = document.getElementById("galerie");
  if (dlg && typeof dlg.showModal === "function") {
    const titelEl = dlg.querySelector(".galerie-titel");
    const zaehlerEl = dlg.querySelector(".zaehler");
    const buehne = dlg.querySelector(".galerie-buehne figure");
    const leiste = dlg.querySelector(".galerie-leiste");
    let bilder = [];
    let index = 0;

    function zeige(i) {
      index = (i + bilder.length) % bilder.length;
      const b = bilder[index];
      buehne.innerHTML = "";
      const img = document.createElement("img");
      img.src = b.src;
      img.alt = b.alt;
      const cap = document.createElement("figcaption");
      cap.textContent = b.text;
      buehne.append(img, cap);
      zaehlerEl.textContent = `${index + 1} / ${bilder.length}`;
      leiste.querySelectorAll("button").forEach((t, j) => t.setAttribute("aria-current", j === index));
      leiste.children[index]?.scrollIntoView({ block: "nearest", inline: "center" });
      // nächstes Bild vorladen
      const naechstes = bilder[(index + 1) % bilder.length];
      if (naechstes) new Image().src = naechstes.src;
    }

    function oeffne(raum, titel) {
      const tpl = document.getElementById("galerie-" + raum);
      if (!tpl) return;
      bilder = [...tpl.content.querySelectorAll("figure")].map((f) => ({
        src: f.querySelector("img").getAttribute("src"),
        alt: f.querySelector("img").getAttribute("alt") || "",
        text: f.querySelector("figcaption")?.textContent || "",
      }));
      titelEl.textContent = titel;
      leiste.innerHTML = "";
      bilder.forEach((b, j) => {
        const t = document.createElement("button");
        t.type = "button";
        t.setAttribute("aria-label", `Bild ${j + 1} anzeigen`);
        t.innerHTML = `<img src="${b.src}" alt="" loading="lazy">`;
        t.addEventListener("click", () => zeige(j));
        leiste.appendChild(t);
      });
      dlg.showModal();
      zeige(0);
    }

    document.querySelectorAll("[data-raum]").forEach((k) =>
      k.addEventListener("click", () => {
        k.closest("dialog.info")?.close(); // aus einem Angebots-Dialog heraus: den zuerst schließen
        oeffne(k.dataset.raum, k.dataset.titel);
      })
    );
    dlg.querySelector(".schliessen").addEventListener("click", () => dlg.close());
    dlg.querySelector(".zurueck").addEventListener("click", () => zeige(index - 1));
    dlg.querySelector(".weiter").addEventListener("click", () => zeige(index + 1));
    dlg.addEventListener("keydown", (e) => {
      if (e.key === "ArrowLeft") zeige(index - 1);
      if (e.key === "ArrowRight") zeige(index + 1);
    });

    // Wischen auf dem Handy
    let startX = null;
    const b = dlg.querySelector(".galerie-buehne");
    b.addEventListener("touchstart", (e) => (startX = e.touches[0].clientX), { passive: true });
    b.addEventListener("touchend", (e) => {
      if (startX === null) return;
      const dx = e.changedTouches[0].clientX - startX;
      if (Math.abs(dx) > 40) zeige(index + (dx < 0 ? 1 : -1));
      startX = null;
    });
  }
}
