#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
coop_extra_screenshot_to_pdf.py

- Åpner Coop Extra kundeavis (https://www.coop.no/coop-extra/kundeavis)
- Lukker cookie-banner og nyhetsbrev-popup (klikk eller fjern via JS)
- Tar skjermbilde av hver side og lagrer som PNG
- Klikker 'neste'-knapp for å bla til neste side
- Når ingen flere sider, slår PNG-ene sammen til én PDF ved bruk av Pillow
- Logger alle steg på norsk, kjører i synlig modus (headless=False), høy oppløsning
"""

from playwright.sync_api import sync_playwright, TimeoutError
from PIL import Image
import hashlib
from datetime import date
from pathlib import Path
import os
import time
import traceback

# Konfigurasjon
URL = "https://kundeavis.coop.no/aviser/?id=4231"
STORE = "coop_extra"
BASE_DIR = Path(__file__).resolve().parents[1]
EGEN_AVIS_DIR = BASE_DIR / "kundeaviser" / "Egen_avis" / STORE
DATE_STR = date.today().strftime("%Y-%m-%d")
DATE_DIR = EGEN_AVIS_DIR / DATE_STR
PART_BASENAME = "part"
PNG_FILENAME = f"{STORE}_avis_{DATE_STR}.png"
VIEWPORT = {"width": 1920, "height": 1080}
MIN_WAIT_AFTER_LOAD = 5
WAIT_BETWEEN_PAGES = 2.5
MAX_PAGES = 300

COOKIE_SELECTORS = [
    "#onetrust-accept-btn-handler",
    "button:has-text('Godta')",
    "button:has-text('Aksepter')",
    "button:has-text('Tillat')",
    "button.cookie-accept",
]

NEXT_SELECTORS = [
    ".swiper-button-next",
    ".arrow-right",
    ".next",
    ".btn-next",
    ".slick-next",
    "div[aria-label='Next']",
    "button[aria-label='Next']",
    "canvas.next",
    ".viewer-next",
    ".pdf-next",
    "a.next",
]


def ensure_output_dir(path: str):
    os.makedirs(path, exist_ok=True)


def save_screenshot(page, path: str):
    try:
        page.screenshot(path=path, full_page=False)
    except Exception:
        page.screenshot(path=path, full_page=True)


def close_cookie_banner(page):
    print("🍪 Søker etter cookie-banner...")
    for sel in COOKIE_SELECTORS:
        try:
            loc = page.locator(sel)
            if loc.count() > 0:
                try:
                    loc.first.click()
                    print(f"✅ Lukket cookie-banner ({sel})")
                    return True
                except Exception:
                    ok = page.evaluate(
                        """(s) => {
                            const el = document.querySelector(s);
                            if (el) { el.click(); return true; }
                            return false;
                        }""",
                        sel,
                    )
                    if ok:
                        print(f"✅ Lukket cookie-banner via JS ({sel})")
                        return True
        except Exception:
            continue
    print("ℹ️ Ingen cookie-banner funnet eller kunne lukkes.")
    return False


def close_newsletter_popup(page):
    """
    Lukker eller fjerner nyhetsbrev-popup for Coop Extra.
    Kombinerer eksplisitt klikk + JS-fjerning.
    """
    print("📮 Søker etter nyhetsbrev-popup (Lukk/X)...")

    NEWSLETTER_SELECTORS = [
        "button:has-text('Lukk')",
        "button:has-text('LUKK')",
        "button:has-text('×')",
        "button:has-text('X')",
        ".newsletter-close",
        ".modal-close",
        ".close-modal",
        ".popup-close",
        ".cookie-popup .close",
        ".popup__close",
        ".mfp-close",
        "button[aria-label='Lukk']",
        "button:has-text('MELD DEG PÅ HER')",  # spesifikk for Coop-popup
    ]

    # --- Trinn 1: prøv å klikke på kjente selektorer ---
    for sel in NEWSLETTER_SELECTORS:
        try:
            loc = page.locator(sel)
            if loc.count() > 0:
                try:
                    loc.first.click()
                    print(f"✅ Lukket popup ({sel})")
                    return True
                except Exception:
                    clicked = page.evaluate(
                        """(s) => {
                            const el = document.querySelector(s);
                            if (el) { try { el.click(); } catch(e) {}; return true; }
                            return false;
                        }""",
                        sel,
                    )
                    if clicked:
                        print(f"✅ Lukket popup via JS-klikk ({sel})")
                        return True
        except Exception:
            continue

    # --- Trinn 2: bred heuristikk hvis knapper ikke funker ---
    print("⚠️ Kunne ikke klikke Lukk-knapp — forsøker å fjerne popup via JS...")
    try:
        removed = page.evaluate(
            """
            () => {
                const keywords = ['nyhetsbrev','newsletter','popup','modal',
                                  'subscribe','abonner','meld deg','e-post'];
                let removedAny = false;

                // Fjern elementer med relevante nøkkelord
                keywords.forEach(k => {
                    const els = Array.from(document.querySelectorAll('*')).filter(e => {
                        const text = (e.innerText || '').toLowerCase();
                        const cls = (e.className || '').toLowerCase();
                        const id = (e.id || '').toLowerCase();
                        return text.includes(k) || cls.includes(k) || id.includes(k);
                    });
                    els.forEach(e => { try { e.remove(); removedAny = true; } catch(_){} });
                });

                // Fjern store overlays med høy z-index
                const overlays = Array.from(document.querySelectorAll('div,section')).filter(e => {
                    try {
                        const s = getComputedStyle(e);
                        return s && (s.position === 'fixed' || s.zIndex && parseInt(s.zIndex) > 1000)
                               && (e.offsetWidth > 200 && e.offsetHeight > 150);
                    } catch(e) { return false; }
                });
                overlays.forEach(o => { try { o.remove(); removedAny = true; } catch(_){} });

                return removedAny;
            }
            """
        )
        if removed:
            print("✅ Popup-elementer fjernet via JS.")
            return True
        else:
            print("ℹ️ Fant ingen popup-elementer å fjerne via JS.")
            return False
    except Exception as e:
        print(f"❌ Feil ved fjerning av popup via JS: {e}")
        return False


def is_locator_clickable(locator) -> bool:
    try:
        if locator.count() == 0:
            return False
        return locator.first.is_visible() and locator.first.is_enabled()
    except Exception:
        return False


def try_click_next(page) -> bool:
    """
    Forsøk å klikke på 'neste-side'-knappen, inkludert bildebasserte piler (img.rm / arrow_rm.png).
    Returnerer True hvis klikk ble utført, False hvis ikke.
    """
    for sel in NEXT_SELECTORS:
        try:
            loc = page.locator(sel)
            if loc.count() > 0:
                if is_locator_clickable(loc):
                    loc.first.click()
                    print(f"➡️ Klikket neste-side-knapp ({sel})")
                    return True
                else:
                    ok = page.evaluate(
                        "(s) => { const el = document.querySelector(s); if (el) { el.click(); return true; } return false; }",
                        sel,
                    )
                    if ok:
                        print(f"➡️ Klikket neste-side via JS ({sel})")
                        return True
        except Exception:
            continue

    # --- Ny fallback: prøv å finne IMG-baserte piler ---
    print("🔎 Søker etter bildebasert neste-knapp (arrow_rm.png)...")
    try:
        ok = page.evaluate(
            """
            () => {
                const imgs = Array.from(document.querySelectorAll('img'));
                for (const img of imgs) {
                    const src = (img.src || '').toLowerCase();
                    const cls = (img.className || '').toLowerCase();
                    // Coop Extra har <img class="rm" src="/aviser/assets/images/arrow_rm.png">
                    if (src.includes('arrow_rm') || cls.includes('rm')) {
                        // prøv å klikke på parent-elementet
                        try {
                            if (img.parentElement) {
                                img.parentElement.click();
                                return true;
                            } else {
                                img.click();
                                return true;
                            }
                        } catch(e) {}
                    }
                }
                return false;
            }
            """
        )
        if ok:
            print("➡️ Klikket bildebasert neste-side (arrow_rm).")
            return True
    except Exception as e:
        print(f"⚠️ Feil ved bildebasert neste-klikk: {e}")

    print("ℹ️ Fant ingen fungerende neste-knapp.")
    return False



def gather_png_paths(output_dir: str):
    files = [
        f for f in os.listdir(output_dir)
        if f.lower().endswith(".png") and f.startswith(f"{PART_BASENAME}_")
    ]
    return [os.path.join(output_dir, f) for f in sorted(files)]


def merge_pngs_to_png(png_paths, output_png_path):
    if not png_paths:
        raise ValueError("Ingen PNG-filer å slå sammen.")
    images = [Image.open(p).convert("RGB") for p in png_paths]
    target_w = max(im.width for im in images)
    scaled = []
    total_h = 0
    for im in images:
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
    size_mb = os.path.getsize(output_png_path) / (1024 * 1024)
    print(f"💾 PNG lagret som {output_png_path} ({size_mb:.2f} MB)")


def delete_png_files(output_dir: str):
    # Vi beholder delbildene i datomappen, ikke slett
    pass


def main():
    ensure_output_dir(str(EGEN_AVIS_DIR))
    ensure_output_dir(str(DATE_DIR))

    try:
        with sync_playwright() as p:
            print("🌐 Starter nettleser (Playwright) i synlig modus...")
            browser = p.chromium.launch(headless=False)
            context = browser.new_context(viewport=VIEWPORT)
            page = context.new_page()
            page.set_default_timeout(30000)

            print(f"🌍 Åpner {URL} ...")
            page.goto(URL, timeout=90000)

            try:
                page.wait_for_selector("body", timeout=15000)
            except TimeoutError:
                print("⚠️ Timeout ved venting på body.")

            time.sleep(MIN_WAIT_AFTER_LOAD)
            close_cookie_banner(page)
            close_newsletter_popup(page)

            print("⏳ Venter på at kundeavis skal laste inn ...")
            try:
                page.wait_for_selector("canvas, img", timeout=20000)
                time.sleep(6)
                print("✅ Første side ferdig lastet.")
            except Exception:
                print("⚠️ Ingen canvas/img funnet – prøver likevel.")

            time.sleep(3)
            close_newsletter_popup(page)

            # --- Første side ---
            png_path = os.path.join(str(DATE_DIR), f"{PART_BASENAME}_001.png")
            save_screenshot(page, png_path)
            print("📸 Lagret første side (001)")

            # --- Hash-oppsett ---
            try:
                html = page.content()
                last_hash = hashlib.md5(html.encode("utf-8")).hexdigest()
            except Exception:
                last_hash = None

            # --- Loop for neste sider ---
            seen_hashes = {last_hash}
            consecutive_same = 0
            MAX_SAME = 1  # stopper etter 2 like på rad
            MAX_FAILS = 2 # stopper hvis next ikke fungerer flere ganger på rad
            fail_count = 0

            for i in range(2, MAX_PAGES + 1):
                print(f"➡️ Forsøker å bla til side {i} ...")
                clicked = try_click_next(page)
                if not clicked:
                    fail_count += 1
                    print(f"⚠️ Neste-knapp ikke funnet ({fail_count}/{MAX_FAILS})")
                    if fail_count >= MAX_FAILS:
                        print("🔚 Ingen fungerende neste-knapp – avslutter.")
                        break
                    time.sleep(2)
                    continue

                fail_count = 0
                # Vent eksplisitt på at neste side faktisk laster
                try:
                    page.wait_for_load_state("networkidle", timeout=15000)
                except Exception:
                    pass
                time.sleep(1.5)

                try:
                    html = page.content()
                    new_hash = hashlib.md5(html.encode("utf-8")).hexdigest()
                except Exception:
                    new_hash = None

                if new_hash == last_hash:
                    consecutive_same += 1
                    print(f"⚠️ Samme side igjen ({consecutive_same}/{MAX_SAME})")
                    if consecutive_same >= MAX_SAME:
                        print("🔚 Samme innhold flere ganger – avslutter.")
                        break
                else:
                    consecutive_same = 0
                    last_hash = new_hash

                png_path = os.path.join(str(DATE_DIR), f"{PART_BASENAME}_{i:02d}.png")
                try:
                    save_screenshot(page, png_path)
                    print(f"📸 Lagret side {i}")
                except Exception as e:
                    print(f"❌ Feil ved screenshot {i}: {e}")
                    break

                time.sleep(WAIT_BETWEEN_PAGES)


            context.close()
            browser.close()

    except Exception as e:
        print("❌ Uventet feil:")
        traceback.print_exc()
        return

    try:
        pngs = gather_png_paths(str(DATE_DIR))
        if not pngs:
            print("❌ Ingen PNG-er funnet. Ingen samlet PNG generert.")
            return
        png_output = os.path.join(str(EGEN_AVIS_DIR), PNG_FILENAME)
        print("🔗 Slår sammen PNG-filer til én PNG ...")
        merge_pngs_to_png(pngs, png_output)
        # Behold delbilder
        print(f"✅ Ferdig: PNG generert: {png_output}")
    except Exception as e:
        print(f"❌ Feil ved sammenslåing til PNG: {e}")
        traceback.print_exc()


if __name__ == "__main__":
    main()
