#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
rema.py

📦 Funksjon:
- Henter REMA 1000 kundeavis automatisk basert på postnummer.
- Bestemmer region (Vest / Øst / Sør / Nord) via REMA sitt API.
- Går direkte til riktig kundeavis-side.
- Hopper over "Egne merkevarer"-lenker.
- Tar skjermbilder av hver side og lager PDF.
"""

from playwright.sync_api import sync_playwright
from PIL import Image
from datetime import date
from pathlib import Path
import requests, os, time, hashlib, traceback


class RemaFetcher:
    def __init__(self, postnummer="5004"):
        self.postnummer = str(postnummer)
        base_path = Path(__file__).resolve().parents[1]
        store = "rema"
        self.egen_avis_dir = base_path / "kundeaviser" / "Egen_avis" / store
        self.date_str = date.today().strftime("%Y-%m-%d")
        self.date_dir = self.egen_avis_dir / self.date_str
        self.egen_avis_dir.mkdir(parents=True, exist_ok=True)
        self.date_dir.mkdir(parents=True, exist_ok=True)
        self.viewport = {"width": 1920, "height": 1080}
        self.png_path = str(self.egen_avis_dir / f"rema1000_avis_{self.date_str}.png")
        self.DELETE_PNGS_AFTER_PDF = False

    # ----------------------------------------------------------
    def _sanitize_dom(self, page):
        """Fjerner cookies og unødvendige popups."""
        try:
            page.evaluate("""
                () => {
                    const bad = ['cookie','consent','popup','modal','banner','newsletter'];
                    document.querySelectorAll('*').forEach(el => {
                        const id=(el.id||'').toLowerCase();
                        const cl=(el.className||'').toLowerCase();
                        if(bad.some(k=>id.includes(k)||cl.includes(k))) el.remove();
                    });
                    document.body.style.overflow='auto';
                }
            """)
        except Exception:
            pass

    def _finn_region(self):
        """Finner region via REMA sitt API ut fra postnummer."""
        try:
            r = requests.get(f"https://www.rema.no/api/kundeavis?postalCode={self.postnummer}", timeout=10)
            data = r.json()
            region = (data.get("region") or "").strip().lower()
            if not region:
                raise ValueError("Tom region fra API")
            print(f"📍 Postnummer {self.postnummer} → region: {region}")
            return region
        except Exception as e:
            print(f"⚠️ Klarte ikke hente region ({e}) – bruker 'vest' som fallback.")
            return "vest"

    def _is_clickable(self, locator):
        try:
            if locator.count() == 0:
                return False
            el = locator.first
            if not el.is_visible():
                return False
            if el.get_attribute("disabled") is not None:
                return False
            aria_dis = (el.get_attribute("aria-disabled") or "").lower() == "true"
            if aria_dis:
                return False
            box = el.bounding_box()
            if not box or box.get("width", 0) <= 2 or box.get("height", 0) <= 2:
                return False
            return True
        except Exception:
            return False

    def _has_next(self, page_or_frame):
        # Spesialhåndtering av Sign verso-knapp: skjules med 'sgn-pp--hidden' på siste side
        try:
            visible = page_or_frame.evaluate("""
                () => {
                  const el = document.querySelector("a.sgn-pp__control[data-direction='next'], button.sgn-pp__control[data-direction='next']");
                  if (!el) return null;
                  const cls = (el.className||'');
                  const hidden = cls.includes('sgn-pp--hidden');
                  const vis = !!(el.offsetParent !== null);
                  return (!hidden) && vis;
                }
            """)
            if visible is not None:
                return bool(visible)
        except Exception:
            pass

        sels = [
            "button[aria-label*='Neste' i]",
            "[role='button'][aria-label*='Neste' i]",
            "button[aria-label*='Neste side' i]",
            "button[title*='Neste' i]",
            "a[aria-label*='Neste' i]",
            "[data-testid*='next' i]",
            "[data-action='next']",
            "[data-direction='next']",
            ".sgn-pp__control--next",
            "a.sgn-pp__control[data-direction='next']",
            "button.sgn-pp__control[data-direction='next']",
            ".swiper-button-next",
            ".slick-next",
            ".splide__arrow--next",
            ".embla__button--next",
            ".glider-next",
            ".keen-slider__arrow--right",
            ".carousel-control-next",
            "button:has(svg use[href='#svg-icon-next'])",
            "button:has(svg use[xlink\:href='#svg-icon-next'])",
        ]
        for s in sels:
            try:
                loc = page_or_frame.locator(s)
                if self._is_clickable(loc):
                    return True
            except Exception:
                continue
        return False

    def _try_click_next(self, page_or_frame):
        """Klikker neste-side-knapp hvis mulig (REMA-spesifikk + generisk fallback)."""
        selectors = [
            "a.sgn-pp__control[data-direction='next']",
            "button.sgn-pp__control[data-direction='next']",
            "a[role='button'][data-direction='next']",
            "a[aria-label*='Neste' i]",
            "button[aria-label*='Neste side' i]",
            "button[title*='Neste' i]",
            ".swiper-button-next",
            ".slick-next",
            ".splide__arrow--next",
            ".embla__button--next",
            ".glider-next",
            ".keen-slider__arrow--right",
            ".carousel-control-next",
        ]
        for s in selectors:
            try:
                loc = page_or_frame.locator(s)
                if loc.count() > 0 and loc.first.is_visible():
                    box = loc.first.bounding_box()
                    if box:
                        print(f"➡️ Klikker neste-knapp ({s}) på posisjon x={int(box['x'])}, y={int(box['y'])}")
                    loc.first.click()
                    time.sleep(1)
                    return True
            except Exception as e:
                print(f"⚠️ Klikkfeil ({s}): {e}")
                continue

        # 1) Prøv å vise knappen via hover og klikk på nytt
        try:
            page_or_frame.mouse.move( int(page_or_frame.viewport_size["width"]*0.85), int(page_or_frame.viewport_size["height"]*0.5) )
            time.sleep(0.2)
            for s in selectors:
                try:
                    loc = page_or_frame.locator(s)
                    if loc.count() > 0:
                        loc.first.click()
                        time.sleep(0.3)
                        return True
                except Exception:
                    continue
        except Exception:
            pass

        # Hvis ingen selector fungerte, prøv JS-klikk på selve elementet via data-direction
        try:
            clicked = page_or_frame.evaluate("""
                () => {
                    const el = document.querySelector("a[data-direction='next'], button[data-direction='next']");
                    if (el) {
                        // Fjern eventuell 'skjult' klasse og simuler ekte klikk
                        el.classList?.remove('sgn-pp--hidden');
                        const evt = new MouseEvent('click', {bubbles:true, cancelable:true, view:window});
                        el.dispatchEvent(evt);
                        return true;
                    }
                    return false;
                }
            """)
            if clicked:
                print("➡️ Klikket neste via JS (data-direction='next').")
                return True
        except Exception as e:
            print(f"⚠️ JS-fallback feilet: {e}")

        # Til slutt: klikk på høyre side av viewer (fysisk koordinatklikk)
        try:
            print("➡️ Klikker høyre side av skjermen (koordinat fallback).")
            vs = page_or_frame.page.viewport_size if hasattr(page_or_frame, 'page') else page_or_frame.viewport_size
            page_or_frame.mouse.click(int(vs["width"]*0.92), int(vs["height"]*0.5))
            time.sleep(1)
            return True
        except Exception:
            pass

        # Som siste utvei – bruk tastatur
        try:
            # Sikre fokus først
            try:
                page_or_frame.locator('body').focus()
            except Exception:
                pass
            page_or_frame.keyboard.press("ArrowRight")
            time.sleep(0.2)
            page_or_frame.keyboard.press("PageDown")
            print("➡️ Sendte ArrowRight-tast.")
            return True
        except Exception:
            pass

        print("⚠️ Fant ingen måte å gå videre på.")
        return False


    # ----------------------------------------------------------
    def hent_pdf(self):
        try:
            region = self._finn_region()
            url = f"https://www.rema.no/kundeaviser/{region}/"

            with sync_playwright() as p:
                browser = p.chromium.launch(headless=False)
                context = browser.new_context(viewport=self.viewport)
                page = context.new_page()

                print(f"🌐 Åpner {url}")
                page.goto(url, timeout=90000)
                page.wait_for_timeout(4000)
                self._sanitize_dom(page)

                # --- Åpne riktig kundeavis ---
                print("🔍 Søker etter kundeavis-knapper (hopper over 'egne merkevarer') ...")
                opened = False

                # Finn alle mulige knapper/lenker som kan åpne kundeavis
                candidates = page.locator(
                    "a:has-text('Klikk for å lese'), a:has-text('Trykk for å lese'), "
                    "button:has-text('Klikk for å lese'), button:has-text('Trykk for å lese')"
                )
                total = candidates.count()
                print(f"📄 Fant {total} kandidat(er) med 'Klikk for å lese'.")

                for i in range(total):
                    try:
                        el = candidates.nth(i)
                        href = (el.get_attribute("href") or "").strip().lower()

                        # hopp over "egne merkevarer"
                        if "/egne-merkevarer" in href:
                            continue

                        print(f"🖱️ Klikker kandidat {i+1}/{total} (href={href or 'tom'}) ...")

                        try:
                            with context.expect_page(timeout=7000) as newp:
                                el.click(force=True)
                            new_page = newp.value
                            new_page.wait_for_load_state("domcontentloaded", timeout=15000)
                            page = new_page
                            opened = True
                            break
                        except Exception:
                            # hvis ingen ny fane åpnes – kanskje samme side
                            el.click(force=True)
                            page.wait_for_load_state("domcontentloaded")
                            opened = True
                            break
                    except Exception:
                        continue

                if not opened:
                    print("❌ Fant ingen gyldig kundeavis-lenke som kunne åpnes.")
                    browser.close()
                    return

                print(f"✅ Kundeavis åpnet: {page.url}")
                page.wait_for_timeout(4000)
                self._sanitize_dom(page)


                # --- Screenshot-loop ---
                print("📸 Starter opptak av sider ...")
                screenshots = []
                seen_hashes = set()

                # Arbeid i page og ev. iframes (noen viewere kjører i iframe)
                work_targets = [page] + [f for f in page.frames if f != page.main_frame]
                for i in range(1, 150):
                    png_path = str(self.date_dir / f"part_{i:02d}.png")
                    try:
                        page.screenshot(path=png_path, full_page=False)
                        screenshots.append(png_path)
                        print(f"📸 Lagret side {i}")
                    except Exception as e:
                        print(f"⚠️ Feil ved screenshot side {i}: {e}")
                        break

                    # stopp hvis ingen neste-knapp
                    if not any(self._has_next(t) for t in work_targets):
                        print("🔚 Ingen neste-knapp synlig – antatt siste side.")
                        break

                    # klikk neste
                    clicked_any = False
                    for t in work_targets:
                        if self._try_click_next(t):
                            clicked_any = True
                            break
                    if not clicked_any:
                        print("🔚 Klarte ikke å klikke neste – stopper.")
                        break

                    time.sleep(2.5)
                    self._sanitize_dom(page)

                    # stopp hvis samme bilde gjentas
                    try:
                        with open(png_path, "rb") as f:
                            img_hash = hashlib.md5(f.read()).hexdigest()
                        if img_hash in seen_hashes:
                            print("🔚 Oppdaget duplikatside – avslutter.")
                            break
                        seen_hashes.add(img_hash)
                    except Exception:
                        pass

                # --- Lag én samlet PNG ---
                if screenshots:
                    print("🔗 Slår sammen PNG-er til én PNG ...")
                    imgs = [Image.open(p).convert("RGB") for p in screenshots]
                    target_w = max(im.width for im in imgs)
                    scaled = []
                    total_h = 0
                    for im in imgs:
                        if im.width != target_w:
                            h = int(im.height * (target_w / im.width))
                            im = im.resize((target_w, h))
                        scaled.append(im)
                        total_h += im.height
                    canvas = Image.new("RGB", (target_w, total_h), "white")
                    y = 0
                    for im in scaled:
                        canvas.paste(im, (0, y))
                        y += im.height
                    canvas.save(self.png_path)
                    print(f"✅ PNG lagret som {self.png_path}")
                    if self.DELETE_PNGS_AFTER_PDF:
                        # Nå beholder vi delbildene i datomappen
                        pass
                else:
                    print("❌ Ingen sider ble lagret.")

                browser.close()
        except Exception:
            traceback.print_exc()
            print("❌ Kritisk feil under henting av REMA 1000 kundeavis.")


# ---------------- RUN SCRIPT ----------------
if __name__ == "__main__":
    RemaFetcher("5004").hent_pdf()
