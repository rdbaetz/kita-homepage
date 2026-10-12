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

// Sanftes Einblenden beim Scrollen
const reveals = document.querySelectorAll(".reveal");
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
