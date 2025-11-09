#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
bunnpris.py

- Åpner Bunnpris Torggaten #kundeavis
- Lukker cookies / popups
- Tar skjermbilde av hver side (selve viewer-elementet)
- Klikker kun 'Neste' (data-direction="next")
- Stopper når teller viser siste side eller når innhold ikke endrer seg
- Lager PDF av sidene (sletter PNG etterpå)
"""

from playwright.sync_api import sync_playwright
from PIL import Image
from datetime import date
from pathlib import Path
import os, time, hashlib, traceback, re

# -------------------- Konfig --------------------
URL = "https://www.bunnpris.no/butikker/bunnpris-torggaten#kundeavis"
STORE = "bunnpris"
BASE_DIR = Path(__file__).resolve().parents[1]
EGEN_AVIS_DIR = BASE_DIR / "kundeaviser" / "Egen_avis" / STORE
DATE_STR = date.today().strftime("%Y-%m-%d")
DATE_DIR = EGEN_AVIS_DIR / DATE_STR
PNG_FILENAME = f"{STORE}_avis_{DATE_STR}.png"
PART_BASENAME = "part"
VIEWPORT = {"width": 1920, "height": 1080}
WAIT_AFTER_LOAD = 4
WAIT_BETWEEN_PAGES = 2.2
MAX_PAGES = 120
DELETE_PNGS_AFTER_PDF = False
# ------------------------------------------------

def ensure_output_dir(path):
    os.makedirs(path, exist_ok=True)

def close_popups(page):
    print("🍪 Lukker cookies/popup ...")
    try:
        selectors = [
            "#onetrust-accept-btn-handler",
            "button:has-text('Godta')",
            "button:has-text('Aksepter alle')",
            "button:has-text('Accept all')",
            "button:has-text('Kun nødvendige')",
            "button:has-text('OK')",
        ]
        for sel in selectors:
            loc = page.locator(sel)
            if loc.count() > 0 and loc.first.is_visible():
                loc.first.click()
                print(f"✅ Lukket popup ({sel})")
                break
        # JS fallback (fjerner generiske overlays)
        page.evaluate("""
            () => {
                document.querySelectorAll('[role=dialog], .modal, .popup, .cookie, .banner')
                    .forEach(e => e.remove());
                document.body.style.overflow='auto';
            }
        """)
    except Exception as e:
        print(f"⚠️ Popup-fjerning feilet: {e}")

def merge_pngs_to_png(png_paths, output_png_path):
    if not png_paths:
        raise ValueError("Ingen PNG-filer å slå sammen.")
    imgs = [Image.open(p).convert("RGB") for p in png_paths]
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
    canvas.save(output_png_path)
    size = os.path.getsize(output_png_path) / (1024 * 1024)
    print(f"💾 Lagret PNG som {output_png_path} ({size:.2f} MB)")

def is_clickable(locator):
    try:
        if locator.count() == 0:
            return False
        el = locator.first
        if not el.is_visible():
            return False
        if (el.get_attribute("aria-disabled") or "").lower() == "true":
            return False
        box = el.bounding_box()
        if not box or box.get("width", 0) < 10 or box.get("height", 0) < 10:
            return False
        return True
    except Exception:
        return False

def has_next(page):
    # Kun ekte "neste" – ikke "last"
    sel = "button.sgn-pp__control[data-direction='next'], a.sgn-pp__control[data-direction='next']"
    try:
        loc = page.locator(sel)
        return is_clickable(loc)
    except Exception:
        return False

def try_click_next(page):
    # Foretrekk eksplisitt next
    selectors = [
        "button.sgn-pp__control[data-direction='next']",
        "a.sgn-pp__control[data-direction='next']",
    ]
    for sel in selectors:
        try:
            loc = page.locator(sel)
            if is_clickable(loc):
                loc.first.click()
                print(f"➡️ Klikket neste ({sel})")
                return True
        except Exception as e:
            print(f"⚠️ Klikkfeil ({sel}): {e}")

    # JS-fallback via data-direction="next"
    try:
        clicked = page.evaluate("""
            () => {
                const el = document.querySelector("[data-direction='next']");
                if (el && el.offsetParent !== null) { el.click(); return true; }
                return false;
            }
        """)
        if clicked:
            print("➡️ Klikket neste via JS-fallback.")
            return True
    except Exception:
        pass

    # Fysisk klikk på høyre side (siste utvei)
    try:
        page.mouse.click(page.viewport_size["width"] - 40, page.viewport_size["height"] / 2)
        print("➡️ Klikket høyre side (fallback).")
        return True
    except Exception:
        pass

    print("⚠️ Fant ingen måte å klikke neste på.")
    return False

def get_page_counter_text(page):
    """Prøv å lese 'x / y' teller fra viewer (hvis den finnes)."""
    try:
        # generisk match av tekst som inneholder 'num / num'
        loc = page.locator("text=/\\d+\\s*\\/\\s*\\d+/")
        if loc.count() > 0:
            return loc.first.inner_text().strip()
    except Exception:
        pass
    return ""

def parse_counter(counter_text):
    """Returner (current, total) fra 'x / y', ellers (None, None)."""
    m = re.search(r"(\d+)\s*/\s*(\d+)", counter_text)
    if not m:
        return None, None
    try:
        return int(m.group(1)), int(m.group(2))
    except Exception:
        return None, None

def screenshot_current_page(page, path):
    """Ta screenshot av selve avis-elementet for stabilitet."""
    try:
        viewer = page.locator(".publication-page, .pageimage, .spread-elements, canvas, .fp-canvas")
        if viewer.count() > 0 and viewer.first.is_visible():
            viewer.first.screenshot(path=path)
            return
    except Exception:
        pass
    # fallback
    page.screenshot(path=path, full_page=False)

def main():
    ensure_output_dir(str(EGEN_AVIS_DIR))
    ensure_output_dir(str(DATE_DIR))
    screenshots = []

    with sync_playwright() as p:
        browser = p.chromium.launch(headless=False)
        context = browser.new_context(viewport=VIEWPORT)
        page = context.new_page()

        print(f"🌐 Åpner {URL} ...")
        page.goto(URL, timeout=90000)
        time.sleep(WAIT_AFTER_LOAD)
        close_popups(page)

        # Gi viewer litt tid til å tegne første side
        try:
            page.wait_for_selector(".publication-page, .pageimage, canvas", timeout=15000)
        except Exception:
            pass
        time.sleep(1.5)

        print("📸 Starter screenshots av sider ...")
        same_hash_hits = 0
        prev_dom_hash = None

        for i in range(1, MAX_PAGES + 1):
            png_path = os.path.join(str(DATE_DIR), f"{PART_BASENAME}_{i:02d}.png")

            # 1) Screenshot av selve siden
            try:
                screenshot_current_page(page, png_path)
                screenshots.append(png_path)
                print(f"📸 Lagret side {i}")
            except Exception as e:
                print(f"❌ Feil ved screenshot side {i}: {e}")
                break

            # 2) Teller-sjekk: stopp hvis siste side
            counter_text = get_page_counter_text(page)
            cur, tot = parse_counter(counter_text)
            if cur is not None and tot is not None:
                print(f"🧮 Teller: {cur}/{tot}")
                if cur >= tot:
                    print("🔚 Nådd siste side (teller). Stopper.")
                    break

            # 3) DOM-hash før neste-klikking
            try:
                dom_before = page.content()
                dom_hash_before = hashlib.md5(dom_before.encode("utf-8")).hexdigest()
            except Exception:
                dom_hash_before = None

            # 4) Klikk neste
            if not has_next(page):
                print("🔚 Ingen neste-knapp tilgjengelig – antatt siste side.")
                break

            if not try_click_next(page):
                print("🔚 Klarte ikke å klikke neste – stopper.")
                break

            time.sleep(WAIT_BETWEEN_PAGES)

            # 5) DOM-hash etter klikk – oppdag evig loop
            try:
                dom_after = page.content()
                dom_hash_after = hashlib.md5(dom_after.encode("utf-8")).hexdigest()
            except Exception:
                dom_hash_after = None

            if dom_hash_before and dom_hash_after and dom_hash_before == dom_hash_after:
                same_hash_hits += 1
                print(f"⚠️ Ingen DOM-endring etter neste (x{same_hash_hits})")
                if same_hash_hits >= 2:
                    print("🔚 Ingen endring 2 ganger – antatt slutt.")
                    break
            else:
                same_hash_hits = 0

        # 6) Slå sammen til én PNG
        try:
            png_path = os.path.join(str(EGEN_AVIS_DIR), PNG_FILENAME)
            print("🔗 Slår sammen PNG-filer til én PNG ...")
            merge_pngs_to_png(screenshots, png_path)
            # Behold delbilder i datomappen
        except Exception as e:
            print(f"❌ Feil ved generering av samlet PNG: {e}")

        browser.close()
        print("✅ Ferdig!")

if __name__ == "__main__":
    try:
        main()
    except Exception:
        traceback.print_exc()
        print("❌ Uventet feil i bunnpris.py")
