// Kita St. Laurentius Neufang – kleine Helfer (kein Framework nötig)

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

// Schatten unter dem Header beim Scrollen
const header = document.querySelector(".site-header");
const onScroll = () => header && header.classList.toggle("scrolled", window.scrollY > 8);
window.addEventListener("scroll", onScroll, { passive: true });
onScroll();

// Aktiven Menüpunkt markieren
const links = [...document.querySelectorAll('.main-nav a[href^="#"]')];
const sections = links.map((a) => document.querySelector(a.getAttribute("href"))).filter(Boolean);
if ("IntersectionObserver" in window && sections.length) {
  const spy = new IntersectionObserver(
    (entries) => {
      entries.forEach((entry) => {
        if (!entry.isIntersecting) return;
        links.forEach((a) => a.classList.toggle("active", a.getAttribute("href") === "#" + entry.target.id));
      });
    },
    { rootMargin: "-45% 0px -50% 0px" }
  );
  sections.forEach((s) => spy.observe(s));
}

// Angebote: Detail-Dialoge
document.querySelectorAll("[data-dialog]").forEach((btn) => {
  const dlg = document.getElementById(btn.dataset.dialog);
  if (!dlg || typeof dlg.showModal !== "function") return;
  btn.addEventListener("click", () => dlg.showModal());
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

// Lesefortschritt oben im Header
const bar = document.createElement("div");
bar.className = "progress";
bar.setAttribute("aria-hidden", "true");
header?.appendChild(bar);

// "Nach oben"-Knopf
const topBtn = document.createElement("a");
topBtn.href = "#start";
topBtn.className = "to-top";
topBtn.setAttribute("aria-label", "Nach oben");
topBtn.innerHTML = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round"><path d="M12 19V5M6 11l6-6 6 6"/></svg>';
document.body.appendChild(topBtn);

// Hero: leichte Tiefenwirkung beim Scrollen
const heroArt = document.querySelector(".hero-art");
const heroText = document.querySelector(".hero-text");

let ticking = false;
function onScrollFrame() {
  const y = window.scrollY;
  const max = document.documentElement.scrollHeight - window.innerHeight;
  bar.style.transform = `scaleX(${max > 0 ? y / max : 0})`;
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

// Angesprungene Überschrift kurz hervorheben
document.querySelectorAll('a[href^="#"]').forEach((a) => {
  a.addEventListener("click", () => {
    const ziel = document.querySelector(a.getAttribute("href"));
    const h = ziel?.querySelector("h2");
    if (!h || reduceMotion) return;
    let erledigt = false;
    const markieren = () => {
      if (erledigt) return;
      erledigt = true;
      h.classList.remove("arrived");
      void h.offsetWidth; // Animation neu starten
      h.classList.add("arrived");
    };
    document.addEventListener("scrollend", markieren, { once: true });
    setTimeout(markieren, 1100); // Fallback, falls "scrollend" nicht unterstützt wird
  });
});
