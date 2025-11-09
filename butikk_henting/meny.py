#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
meny_kundeavis_screenshots_to_pdf.py

- Åpner https://meny.no/kundeavis/
- Lukker cookies / popup
- Klikker på "MENY papiravis"
- Tar skjermbilde av hver side i kundeavisen
- Klikker på "neste" (SVG med xlink:href="#svg-icon-next") for å bla
- Slår sammen PNG-ene til én PDF med Pillow
"""

from playwright.sync_api import sync_playwright, TimeoutError
from PIL import Image
from datetime import date
from pathlib import Path
import os, time, hashlib, traceback

# -------------------- Konfig --------------------
URL = "https://meny.no/kundeavis/"
STORE = "meny"
BASE_DIR = Path(__file__).resolve().parents[1]
EGEN_AVIS_DIR = BASE_DIR / "kundeaviser" / "Egen_avis" / STORE
DATE_STR = date.today().strftime("%Y-%m-%d")
DATE_DIR = EGEN_AVIS_DIR / DATE_STR
PNG_FILENAME = f"{STORE}_avis_{DATE_STR}.png"
VIEWPORT = {"width": 1920, "height": 1080}
WAIT_AFTER_LOAD = 4
WAIT_BETWEEN_PAGES = 2.5
MAX_PAGES = 80
# Slett PNG-ene når PDF er lagret
DELETE_PNGS_AFTER_PDF = False
# ------------------------------------------------


def ensure_output_dir(path):
    os.makedirs(path, exist_ok=True)


def save_screenshot(page, path):
    """Tar skjermbilde av viewport."""
    try:
        page.screenshot(path=path, full_page=False)
    except Exception:
        page.screenshot(path=path, full_page=True)


def close_popups(page):
    """Lukker cookies og popup med flere strategier."""
    print("🍪 Lukker cookies/popup ...")
    selectors = [
        "#onetrust-accept-btn-handler",
        "button:has-text('Godta')",
        "button:has-text('Aksepter alle')",
        "button:has-text('Accept all')",
        "button:has-text('Kun nødvendige')",
        "button:has-text('OK')",
    ]
    for sel in selectors:
        try:
            if page.locator(sel).count() > 0:
                page.locator(sel).first.click()
                print(f"✅ Lukket popup ({sel})")
                return
        except:
            continue
    # JS fallback
    try:
        page.evaluate("""
            () => {
                document.querySelectorAll('[role=dialog], .modal, .popup, .cookie, .banner')
                    .forEach(e => e.remove());
            }
        """)
        print("✅ Fjernet popup-elementer via JS.")
    except Exception as e:
        print(f"⚠️ JS-fjerning feilet: {e}")


def merge_pngs_to_png(png_paths, output_png_path):
    """Stitch PNG-filer vertikalt til én PNG."""
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


def is_clickable_handle(page_or_frame, locator):
    try:
        if locator.count() == 0:
            return False
        loc = locator.first
        if not loc.is_visible():
            return False
        aria_disabled = (loc.get_attribute("aria-disabled") or "").lower() == "true"
        disabled = loc.get_attribute("disabled") is not None
        if aria_disabled or disabled:
            return False
        # also check size
        box = loc.bounding_box()
        if not box or box.get("width", 0) <= 2 or box.get("height", 0) <= 2:
            return False
        return True
    except Exception:
        return False


def try_click_next(page_or_frame):
    """Prøv flere strategier for å gå til neste side i viewer.

    Returnerer True hvis vi sannsynligvis navigerte, ellers False.
    """
    selectors = [
        # Direkte knapper/lenker med semantikk
        "button[aria-label*='Neste' i]",
        "button[aria-label*='Next' i]",
        "[role='button'][aria-label*='Neste' i]",
        "a[aria-label*='Neste' i]",
        "[data-testid*='next' i]",
        # SVG-varianten (ny og gammel xlink)
        "button:has(svg use[href='#svg-icon-next'])",
        "button:has(svg use[xlink\\:href='#svg-icon-next'])",
        "a:has(svg use[href='#svg-icon-next'])",
        "a:has(svg use[xlink\\:href='#svg-icon-next'])",
        "[role='button']:has(svg use[href='#svg-icon-next'])",
        "[role='button']:has(svg use[xlink\\:href='#svg-icon-next'])",
    ]

    # 1) Forsøk klikk via robuste Playwright-selektorer
    for sel in selectors:
        try:
            loc = page_or_frame.locator(sel)
            if is_clickable_handle(page_or_frame, loc):
                loc.first.click(timeout=2000)
                print(f"➡️ Klikket neste ({sel})")
                return True
        except Exception:
            continue

    # 2) Forsøk å finne <use> og klikke nærmeste klikkbare forfader via JS
    try:
        ok = page_or_frame.evaluate(
            """
            () => {
              const use = document.querySelector("use[href='#svg-icon-next'], use[xlink\\:href='#svg-icon-next']");
              if (!use) return false;
              const clickable = use.closest('button, a, [role=button], .button, .btn, .o-icon');
              if (clickable) { clickable.click(); return true; }
              const svg = use.closest('svg');
              if (svg && svg.click) { svg.click(); return true; }
              return false;
            }
            """
        )
        if ok:
            print("➡️ Klikket neste via JS-fallback.")
            return True
    except Exception:
        pass

    # 3) Prøv piltast høyre – mange viewere støtter dette
    try:
        page_or_frame.keyboard.press("ArrowRight")
        print("➡️ Sendte ArrowRight-tast.")
        return True
    except Exception:
        pass

    return False


def has_next(page_or_frame):
    """Returner True hvis en 'Neste'-kontroll er synlig og ikke deaktivert."""
    selectors = [
        "button[aria-label*='Neste' i]",
        "button[aria-label*='Next' i]",
        "[role='button'][aria-label*='Neste' i]",
        "a[aria-label*='Neste' i]",
        "[data-testid*='next' i]",
        "button:has(svg use[href='#svg-icon-next'])",
        "button:has(svg use[xlink\\:href='#svg-icon-next'])",
        "a:has(svg use[href='#svg-icon-next'])",
        "a:has(svg use[xlink\\:href='#svg-icon-next'])",
        "[role='button']:has(svg use[href='#svg-icon-next'])",
        "[role='button']:has(svg use[xlink\\:href='#svg-icon-next'])",
    ]
    for sel in selectors:
        try:
            loc = page_or_frame.locator(sel)
            if is_clickable_handle(page_or_frame, loc):
                return True
        except Exception:
            continue
    return False


def main():
    ensure_output_dir(str(EGEN_AVIS_DIR))
    ensure_output_dir(str(DATE_DIR))
    screenshots = []

    with sync_playwright() as p:
        browser = p.chromium.launch(headless=False)
        context = browser.new_context(viewport=VIEWPORT)
        page = context.new_page()

        print(f"🌐 Åpner {URL} ...")
        page.goto(URL, timeout=60000)
        time.sleep(WAIT_AFTER_LOAD)

        close_popups(page)
        time.sleep(1)

        # Klikk på "MENY papiravis" – håndter både ny fane og samme-side navigasjon
        avis_page = None
        try:
            print("🖱️ Klikker på bildet 'MENY papiravis' ...")
            link_href = page.locator("img[alt='MENY papiravis']").first.evaluate(
                "el => (el.closest('a') && el.closest('a').href) || null"
            )

            # Forsøk ny fane først (noen ganger åpnes viewer i nytt vindu)
            got_new_page = False
            try:
                with context.expect_page(timeout=5000) as new_page_info:
                    if link_href:
                        # Foretrekk å åpne direkte URL hvis vi har href
                        page.evaluate("url => window.open(url, '_blank')", link_href)
                    else:
                        page.locator("img[alt='MENY papiravis']").first.evaluate(
                            "el => el.closest('a')?.click()"
                        )
                avis_page = new_page_info.value
                avis_page.wait_for_load_state("domcontentloaded")
                got_new_page = True
            except Exception:
                got_new_page = False

            if not got_new_page:
                # Fallback: naviger i samme fane
                if link_href:
                    page.goto(link_href, timeout=60000)
                else:
                    page.locator("img[alt='MENY papiravis']").first.click()
                page.wait_for_load_state("domcontentloaded")
                avis_page = page

            print("✅ Åpnet kundeavis-viewer!")
        except Exception as e:
            print(f"❌ Klarte ikke åpne papiravis: {e}")
            browser.close()
            return

        time.sleep(3)

        print("📸 Starter screenshots av sider ...")
        # Hvis viewer er i iframe – forsøk å jobbe inne i den også
        frames = avis_page.frames
        work_targets = [avis_page] + [f for f in frames if f != avis_page.main_frame]

        seen_hashes = set()
        for i in range(1, MAX_PAGES + 1):
            png_path = os.path.join(str(DATE_DIR), f"part_{i:02d}.png")

            # Ta skjermbilde av siden (øverste nivå-siden for enkelhet)
            try:
                save_screenshot(avis_page, png_path)
                screenshots.append(png_path)
                print(f"📸 Lagret side {i}")
            except Exception as e:
                print(f"❌ Feil ved screenshot side {i}: {e}")
                break

            # Hash av bildet for å oppdage duplisering/looping
            try:
                with open(png_path, "rb") as f:
                    img_bytes = f.read()
                hash_img = hashlib.md5(img_bytes).hexdigest()
            except Exception:
                hash_img = None

            if hash_img:
                if hash_img in seen_hashes:
                    print("🔚 Oppdaget gjentatt side (loop) – stopper.")
                    break
                seen_hashes.add(hash_img)

            # Hvis ingen neste-knapp, så er vi ferdige
            has_next_any = False
            for target in work_targets:
                if has_next(target):
                    has_next_any = True
                    break
            if not has_next_any:
                print("🔚 Ingen neste-knapp synlig – antatt siste side.")
                break

            # Klikk neste i en av kontekster (page eller iframe)
            clicked_any = False
            for target in work_targets:
                if try_click_next(target):
                    clicked_any = True
                    break

            time.sleep(WAIT_BETWEEN_PAGES)

            if not clicked_any:
                print("🔚 Fant ingen måte å gå videre – stopper.")
                break

        # Ferdig – slå sammen til én PNG
        try:
            stitched_path = os.path.join(str(EGEN_AVIS_DIR), PNG_FILENAME)
            print("🔗 Slår sammen PNG-filer til én PNG ...")
            merge_pngs_to_png(screenshots, stitched_path)
        except Exception as e:
            print(f"❌ Feil ved generering av samlet PNG: {e}")
        else:
            if DELETE_PNGS_AFTER_PDF:
                # Behold delbildene i datomappen (standard nå)
                pass

        context.close()
        browser.close()
        print("✅ Ferdig!")


if __name__ == "__main__":
    main()
