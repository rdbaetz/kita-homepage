// Rundgang: Kachel anklicken → Vollbild-Galerie mit Blättern, Tastatur und Wischen.
// Bilder je Raum stehen im HTML in <template id="galerie-RAUM"> als <figure>-Liste.

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
    k.addEventListener("click", () => oeffne(k.dataset.raum, k.querySelector("h3").textContent))
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
