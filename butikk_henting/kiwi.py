#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
KIWI kundeavis – scroller visuelt gjennom PDF-viewer,
lagrer delbilder i datomappe og syr også en samlet PNG.
"""

import os, re, time, urllib.parse
from datetime import date
from pathlib import Path
from playwright.sync_api import sync_playwright
from PIL import Image  # Pillow kreves: pip install pillow
import hashlib

URL_MAIN = "https://kiwi.no/kundeavis"
BASE_DIR = Path(__file__).resolve().parents[1]
STORE = "kiwi"
EGEN_AVIS_DIR = BASE_DIR / "kundeaviser" / "Egen_avis" / STORE
DATE_STR = date.today().strftime("%Y-%m-%d")
DATE_DIR = EGEN_AVIS_DIR / DATE_STR
EGEN_AVIS_DIR.mkdir(parents=True, exist_ok=True)
DATE_DIR.mkdir(parents=True, exist_ok=True)


# -------------------------
# Finn nyeste KIWI-lenke
# -------------------------
def find_latest_kiwi_url(page):
    page.wait_for_selector("a[href*='kundeavis/']", timeout=10000)
    links = page.locator("a[href*='kundeavis/']")
    urls = []
    for i in range(links.count()):
        href = links.nth(i).get_attribute("href")
        if href and re.search(r"kiwi\.no/kundeavis/uke-\d+", href):
            urls.append(urllib.parse.urljoin(URL_MAIN, href))
    if not urls:
        raise RuntimeError("Fant ingen KIWI-lenker")
    urls.sort(key=lambda u: int(re.search(r"uke-(\d+)", u).group(1)), reverse=True)
    return urls[0]


# -------------------------
# Scroll og ta bilder
# -------------------------
def scroll_screenshot(avis_page, delay=1.8, max_scrolls=80):
    """
    Tar screenshots av Chrome PDF-viewer ved å scrolle nedover.
    Fokuserer på embed-elementet for å kunne scrolle i PDF-vieweren.
    """
    print("📸 Starter visuell scrolling ...")

    # Lagre bilder i datomappen
    img_dir = DATE_DIR

    viewport_height = avis_page.viewport_size["height"]
    print(f"🪟 Viewport høyde: {viewport_height}px – Maks {max_scrolls} sidebytter")

    # Vent på at siden er ferdig lastet
    print("⏳ Venter på at PDF-viewer lastes...")
    time.sleep(4)
    
    # Prøv å finne og fokusere på embed-elementet (Chrome PDF viewer)
    print("🎯 Søker etter PDF-viewer...")
    
    # Strategi 1: Klikk på embed-elementet for å gi det fokus
    embed_found = False
    try:
        # Vent på embed element
        avis_page.wait_for_selector("embed", timeout=10000)
        
        # Klikk på embed for å gi det fokus
        embed_box = avis_page.locator("embed").bounding_box()
        if embed_box:
            # Klikk i midten av embed-elementet
            click_x = embed_box["x"] + embed_box["width"] / 2
            click_y = embed_box["y"] + embed_box["height"] / 2
            avis_page.mouse.click(click_x, click_y)
            print(f"✓ Klikket på PDF-viewer (embed) ved ({click_x:.0f}, {click_y:.0f})")
            embed_found = True
            time.sleep(1)
        else:
            print("⚠️ Kunne ikke finne bounding box for embed")
    except Exception as e:
        print(f"⚠️ Kunne ikke finne embed-element: {e}")
    
    # Strategi 2: Prøv å klikke på #content div
    if not embed_found:
        try:
            avis_page.click("#content", timeout=5000)
            print("✓ Klikket på #content div")
            time.sleep(1)
        except Exception as e:
            print(f"⚠️ Kunne ikke klikke på #content: {e}")
    
    # ZOOM UT for å få mer innhold per bilde
    print("🔍 Setter zoomnivå til 50 % ...")
    try:
        avis_page.evaluate("""
            () => {
                const el = document.querySelector('embed, iframe, .pdf-viewer, body');
                if (el) el.style.zoom = '50%';
                document.body.style.zoom = '50%';
            }
        """)
        print("✓ Zoom satt til 50 % via JavaScript")
    except Exception as e:
        print(f"⚠️ Zoom-justering feilet: {e}")
    time.sleep(1)



    
    last_hash = None
    same_counter = 0

    # Ta første bilde før vi begynner å scrolle
    path = img_dir / f"part_{1:02}.png"
    avis_page.screenshot(path=str(path), full_page=False)
    
    with open(path, "rb") as f:
        last_hash = hashlib.md5(f.read()).hexdigest()
    
    print(f"🖼️ Lagret bilde 1 → {path.name}")

    for idx in range(2, max_scrolls + 1):
        # Scroll med flere metoder
        scroll_success = False
        
        # Metode 1: PageDown (beste for Chrome PDF viewer)
        try:
            avis_page.keyboard.press("PageDown")
            scroll_success = True
        except Exception as e:
            print(f"⚠️ PageDown feilet: {e}")
        
        # Metode 2: Arrow Down (hvis PageDown ikke fungerer)
        if not scroll_success:
            try:
                # Trykk ned-pil flere ganger for å simulere PageDown
                for _ in range(5):
                    avis_page.keyboard.press("ArrowDown")
                    time.sleep(0.1)
                scroll_success = True
            except Exception as e:
                print(f"⚠️ ArrowDown feilet: {e}")
        
        # Metode 3: Space (alternative scroll)
        if not scroll_success:
            try:
                avis_page.keyboard.press("Space")
                scroll_success = True
            except Exception as e:
                print(f"⚠️ Space feilet: {e}")
        
        # Vent på at PDF-en rendrer
        time.sleep(delay)
        
        # Ta screenshot
        path = img_dir / f"part_{idx:02}.png"
        avis_page.screenshot(path=str(path), full_page=False)

        # Hash for å sjekke endring
        with open(path, "rb") as f:
            current_hash = hashlib.md5(f.read()).hexdigest()

        if current_hash == last_hash:
            same_counter += 1
            print(f"🖼️ Lagret bilde {idx} → {path.name} (identiske {same_counter}x) ⚠️")
        else:
            same_counter = 0
            print(f"🖼️ Lagret bilde {idx} → {path.name} ✓")
        
        last_hash = current_hash

        # Stopp hvis vi har fått samme bilde 3 ganger på rad
        if same_counter >= 2:
            print("🛑 Ingen endring i skjermen – bunnen nådd!")
            break

    print("🎉 Ferdig med visuelle screenshots!")
    return img_dir


# -------------------------
# Lag én stor PNG av delbilder
# -------------------------
def images_to_png(img_dir: Path, output_path: Path):
    """Syr PNG-bildene i mappen vertikalt til én PNG."""
    images = sorted(img_dir.glob("part_*.png"))
    if not images:
        print("⚠️ Ingen bilder funnet å sette sammen.")
        return

    print(f"🧵 Syr sammen {len(images)} bilder til én PNG ...")
    objs = [Image.open(img).convert("RGB") for img in images]
    target_w = max(im.width for im in objs)
    scaled = []
    total_h = 0
    for im in objs:
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
    canvas.save(output_path)
    size_mb = output_path.stat().st_size / (1024 * 1024)
    print(f"✅ Lagret samlet PNG: {output_path} ({size_mb:.2f} MB)")


# -------------------------
# Slett PNG-filer
# -------------------------
def delete_png_files(img_dir: Path):
    # Vi beholder delbildene i datomappen for OCR
    pass


# -------------------------
# Main
# -------------------------
def main():
    print("🚀 Starter KIWI scrolle-henter ...")

    chrome_profile = Path.home() / "AppData" / "Local" / "PlaywrightChrome"
    chrome_profile.mkdir(parents=True, exist_ok=True)

    with sync_playwright() as p:
        context = p.chromium.launch_persistent_context(
            user_data_dir=str(chrome_profile),
            headless=False,
            args=["--no-sandbox", "--disable-dev-shm-usage", "--start-maximized"],
        )
        page = context.pages[0] if context.pages else context.new_page()

        print(f"🟢 Åpner {URL_MAIN}")
        page.goto(URL_MAIN)
        time.sleep(3)

        for sel in ["#onetrust-accept-btn-handler", "button:has-text('Godta')"]:
            try:
                page.click(sel, timeout=3000)
                print("🍪 Lukket cookie-banner")
                break
            except:
                pass

        latest_url = find_latest_kiwi_url(page)
        print(f"🔗 Fant KIWI-lenke: {latest_url}")

        avis_page = context.new_page()
        avis_page.goto(latest_url)
        avis_page.wait_for_load_state("load")
        print(f"📖 Åpnet kundeavis: {avis_page.url}")
        time.sleep(4)

        img_dir = scroll_screenshot(avis_page)
        stitched = EGEN_AVIS_DIR / f"{STORE}_avis_{DATE_STR}.png"
        images_to_png(img_dir, stitched)
        # Behold delbilder i datomappen

        context.close()
        print("✅ Alt ferdig!")


if __name__ == "__main__":
    main()