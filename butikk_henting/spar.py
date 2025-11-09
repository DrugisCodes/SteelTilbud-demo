#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
spar.py – Henter kundeavis fra SPAR
Oppdatert 2025-11-02
✅ Setter zoom til 50%
✅ Scroller automatisk nedover til slutten
✅ Fallback: klikker på elementer i venstre sidemeny hvis tilgjengelig
✅ Hvis direkte PDF finnes: last ned til raw_pdfs og konverter til delbilder + samlet PNG
"""

from playwright.sync_api import sync_playwright
from PIL import Image
from datetime import date
from pathlib import Path
import os, re, time, hashlib, requests, traceback
try:
    # Valgfri avhengighet for PDF->PNG
    from pdf2image import convert_from_path
except Exception:
    convert_from_path = None


# -------------------- Konfig --------------------
URL = "https://spar.no/spar-kundeavis"
STORE = "spar"
BASE_DIR = Path(__file__).resolve().parents[1]
EGEN_AVIS_DIR = BASE_DIR / "kundeaviser" / "Egen_avis" / STORE
DATE_STR = date.today().strftime("%Y-%m-%d")
DATE_DIR = EGEN_AVIS_DIR / DATE_STR
RAW_PDFS_DIR = BASE_DIR / "kundeaviser" / "raw_pdfs"
PNG_FILENAME = f"{STORE}_avis_{DATE_STR}.png"
PART_BASENAME = "part"
VIEWPORT = {"width": 1920, "height": 1080}
ZOOM = 0.5  # 50% zoom i viewer/siden under screenshots
WAIT_AFTER_LOAD = 5
SCROLL_STEP = 900
SCROLL_OVERLAP = 150
DELETE_PNGS_AFTER_PDF = False
DEBUG = True
# ------------------------------------------------


def log(msg):
    if DEBUG:
        print(f"[🪶 DEBUG] {msg}")


def ensure_output_dir(path):
    os.makedirs(path, exist_ok=True)


def close_popups(page):
    log("Forsøker å lukke cookies...")
    for sel in [
        "#onetrust-accept-btn-handler",
        "button:has-text('Godta')",
        "button:has-text('Aksepter alle')",
        "button:has-text('Accept all')",
        "button:has-text('Kun nødvendige')",
        "button:has-text('OK')",
    ]:
        try:
            if page.locator(sel).count() > 0:
                page.locator(sel).first.click()
                log(f"Lukket popup: {sel}")
                return
        except:
            continue
    try:
        page.evaluate("""() => {
            document.querySelectorAll('[role=dialog], .modal, .popup, .cookie, .banner')
            .forEach(e => e.remove());
        }""")
        log("Fjernet popup via JS.")
    except:
        pass


def merge_pngs_to_png(pngs, dest_png):
    """Stitch alle PNG-er vertikalt til én stor PNG."""
    if not pngs:
        print("❌ Ingen PNG-er å slå sammen.")
        return
    imgs = [Image.open(p).convert("RGB") for p in pngs]
    widths = [im.width for im in imgs]
    target_w = max(widths)
    # Skaler til felles bredde
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
    canvas.save(dest_png)
    size = os.path.getsize(dest_png) / (1024 * 1024)
    print(f"💾 Lagret PNG som {dest_png} ({size:.2f} MB)")


def last_ned_pdf(url, path):
    print(f"⬇️ Laster ned PDF direkte: {url}")
    try:
        r = requests.get(url, timeout=30)
        r.raise_for_status()
        with open(path, "wb") as f:
            f.write(r.content)
        size = os.path.getsize(path) / (1024 * 1024)
        print(f"💾 Lagret PDF som {path} ({size:.2f} MB)")
        return True
    except Exception as e:
        print(f"❌ Nedlasting feilet: {e}")
        return False


def pdf_til_delbilder(pdf_path: Path, dest_dir: Path, dpi: int = 200) -> list[Path]:
    """Konverter en PDF til delbilder (part_01.png, ...) i dest_dir.
    Bruker pdf2image hvis tilgjengelig, ellers returnerer tom liste.
    """
    dest_dir.mkdir(parents=True, exist_ok=True)

    # Rydd gamle part_*.png for å unngå miks
    for old in dest_dir.glob("part_*.png"):
        try:
            old.unlink()
        except Exception:
            pass

    if convert_from_path is None:
        print("⚠️ pdf2image ikke installert – hopper over PDF→PNG-konvertering.")
        return []

    try:
        pages = convert_from_path(str(pdf_path), dpi=dpi)
        out_files: list[Path] = []
        for i, img in enumerate(pages, start=1):
            out = dest_dir / f"part_{i:02d}.png"
            img.convert("RGB").save(out)
            out_files.append(out)
        print(f"🖼️ Konverterte {len(out_files)} sider fra PDF til PNG i {dest_dir}")
        return out_files
    except Exception as e:
        print(f"❌ Kunne ikke konvertere PDF til PNG: {e}")
        return []


def main(postnummer="5004"):
    ensure_output_dir(str(EGEN_AVIS_DIR))
    ensure_output_dir(str(DATE_DIR))
    ensure_output_dir(str(RAW_PDFS_DIR))
    png_path = str(EGEN_AVIS_DIR / PNG_FILENAME)
    pdf_url = None

    with sync_playwright() as p:
        browser = p.chromium.launch(headless=False, slow_mo=150)
        context = browser.new_context(viewport=VIEWPORT)
        page = context.new_page()

        print(f"🌐 Åpner {URL} ...")
        page.goto(URL, timeout=90000)
        page.wait_for_load_state("domcontentloaded")
        time.sleep(WAIT_AFTER_LOAD)
        close_popups(page)

        # --- Skriv inn postnummer ---
        log(f"Skriver inn postnummer {postnummer}")
        felt = page.locator("input[placeholder*='Postnummer' i], input[type='number']")
        if felt.count() == 0:
            print("❌ Fant ikke postnummerfelt.")
            browser.close()
            return
        felt.first.fill(postnummer)
        page.keyboard.press("Enter")
        log("Trykket Enter – venter på kundeavis ...")
        time.sleep(4)

        # --- Finn riktig fane ---
        if len(context.pages) > 1:
            ny_fane = context.pages[-1]
            log("Ny fane oppdaget.")
        else:
            ny_fane = page
            log("Ingen ny fane – bruker samme side.")

        # --- Zoom nivå ---
        try:
            log(f"Setter zoom til {int(ZOOM*100)}% ...")
            ny_fane.evaluate("(z) => { const el = document.documentElement; if(el) el.style.zoom = z; }", f"{int(ZOOM*100)}%")
            time.sleep(1)
        except Exception as e:
            log(f"Kunne ikke sette zoom: {e}")

        # --- Sjekk om det finnes en direkte PDF-lenke ---
        try:
            html = ny_fane.content()
            match = re.search(r"https://cdn\.sanity\.io/files/[^\s\"']+\.pdf", html)
            if match:
                pdf_url = match.group(0)
        except:
            pass

        if not pdf_url and ".pdf" in ny_fane.url:
            pdf_url = ny_fane.url

        if pdf_url:
            pdf_dest = RAW_PDFS_DIR / f"{STORE}_avis_{DATE_STR}.pdf"
            if last_ned_pdf(pdf_url, str(pdf_dest)):
                # Konverter PDF til delbilder + sydd PNG
                parts = pdf_til_delbilder(pdf_dest, DATE_DIR)
                if parts:
                    merge_pngs_to_png([str(p) for p in parts], str(EGEN_AVIS_DIR / PNG_FILENAME))
                    print("✅ Ferdig (PDF lastet ned og konvertert til PNG)")
                else:
                    print("⚠️ PDF ble lastet ned, men ble ikke konvertert – vurder å installere 'pdf2image' og Poppler.")
            try:
                browser.close()
            except Exception:
                pass
            return

        # --- Scroll fallback ---
        print("📸 Ingen direkte PDF – starter scroll-screenshots ...")
        ny_fane.wait_for_load_state("networkidle")
        time.sleep(2)

        # Hent høyde
        total_height = ny_fane.evaluate("document.body.scrollHeight")
        view_h = VIEWPORT["height"]
        log(f"Total høyde: {total_height}px (viewport={view_h})")

        scroll_y = 0
        screenshots = []
        seen_hashes = set()
        stable_count = 0

        for i in range(1, 300):  # maks 300 scrolls
            png_path = str(DATE_DIR / f"{PART_BASENAME}_{i:02d}.png")
            log(f"TAR SKJERMBILDE {i} – scroll_y={scroll_y}")
            ny_fane.screenshot(path=png_path, full_page=False)
            screenshots.append(png_path)

            # hash-sjekk for duplikater
            with open(png_path, "rb") as f:
                h = hashlib.md5(f.read()).hexdigest()
            if h in seen_hashes:
                log("🔚 Samme bilde som forrige – stopper.")
                break
            seen_hashes.add(h)

            scroll_y += SCROLL_STEP
            if scroll_y + view_h >= total_height:
                stable_count += 1
                if stable_count >= 2:
                    log("🔚 Nådd bunnen av dokumentet – stopper.")
                    break
            else:
                stable_count = 0

            ny_fane.evaluate(f"window.scrollTo(0, {scroll_y})")
            time.sleep(1.2)
            # Oppdater total høyde etter hvert scroll
            try:
                total_height = ny_fane.evaluate("document.body.scrollHeight")
            except Exception:
                pass

            # Fallback: prøv å klikke i sidemeny (hamburger/miniatyrer)
            try:
                if i % 10 == 0:  # hvert 10. forsøk
                    log("Prøver å klikke på sidemeny-element ...")
                    ny_fane.evaluate("""
                        () => {
                            const thumbs = document.querySelectorAll('nav a, aside a, .thumbnails a');
                            if (thumbs && thumbs.length > 1) {
                                thumbs[Math.min(thumbs.length-1, 1)].click();
                                return true;
                            }
                            return false;
                        }
                    """)
            except Exception:
                pass

        browser.close()

    # --- Slå sammen til én PNG ---
    if screenshots:
        print("🔗 Slår sammen PNG-er til én PNG ...")
        merge_pngs_to_png(screenshots, png_path)
        if DELETE_PNGS_AFTER_PDF:
            for s in screenshots:
                try:
                    os.remove(s)
                except:
                    pass
            print("🧹 Slettet delbilder etter eksport.")
    else:
        print("❌ Ingen screenshots tatt.")
    print("✅ Ferdig!")


if __name__ == "__main__":
    try:
        main("5004")
    except Exception:
        traceback.print_exc()
        print("❌ Feil i spar.py")
