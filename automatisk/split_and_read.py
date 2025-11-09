#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
split_and_read.py (v4.1 – multipack + fuzzy deduplisering)
- Leser og segmenterer kundeaviser (OpenCV)
- Leser segmenter med GPT (via ai_reader)
- Ekstraherer multipakker, vekt og pris per kg
- Fuzzy-slår sammen like produkter (Billys vs Billy)
- Lagrer resultater og rejects
"""

import os, cv2, json, time, re, shutil
from datetime import date
from pathlib import Path
from rapidfuzz import fuzz
from ai_reader import (
    read_with_ai, normalize_price, remove_duplicates,
    categorize_item, filter_garbage
)
from openai import RateLimitError

# -------------------- KONFIG --------------------
BASE_DIR = Path(__file__).resolve().parents[1]
EGEN_AVIS_DIR = BASE_DIR / "kundeaviser" / "Egen_avis"
RESULT_DIR = BASE_DIR / "resultater"
REJECT_DIR = RESULT_DIR / "rejects"
CHUNK_DIR = RESULT_DIR / "chunks"

for d in [RESULT_DIR, REJECT_DIR, CHUNK_DIR]:
    os.makedirs(d, exist_ok=True)
# ------------------------------------------------


# --- Fuzzy og multipack utils ---
def normalize_name(name: str) -> str:
    """Fjerner OCR-variasjoner og støy fra navn."""
    name = name.lower()
    for w in ["original", "deal", "fast", "big pack", "pk", "stk", "pack"]:
        name = name.replace(w, "")
    return re.sub(r'[^a-zæøå0-9 ]', '', name).strip()


def is_same_product(p1, p2):
    """Returner True hvis to OCR-produkter trolig er samme vare."""
    n1, n2 = normalize_name(p1.get("produkt", "")), normalize_name(p2.get("produkt", ""))
    score = fuzz.ratio(n1, n2)
    if score < 90:
        return False

    # Prisforskjell maks 5 %
    try:
        pr1 = float(p1.get("pris", 0))
        pr2 = float(p2.get("pris", 0))
        if abs(pr1 - pr2) / max(pr1, pr2) > 0.05:
            return False
    except:
        pass

    # Unngå å merge "zero"/"uten sukker"/"lett"/"hel"/"maks"/"mini"
    conflict = ["zero", "uten", "lett", "hel", "maks", "mini"]
    for c in conflict:
        if (c in n1 and c not in n2) or (c in n2 and c not in n1):
            return False

    return True


def deduplicate_fuzzy(products):
    """Slår sammen nesten-like produkter fra OCR."""
    merged = []
    for p in products:
        found = False
        for m in merged:
            if is_same_product(p, m):
                m["kilder"] = list(set(m.get("kilder", []) + [p.get("kilde", "ocr")]))
                try:
                    m["pris"] = min(float(m.get("pris", 9999)), float(p.get("pris", 9999)))
                except:
                    pass
                found = True
                break
        if not found:
            merged.append(p)
    return merged


def extract_weight_and_pack(text: str):
    """Fanger opp vekt og multipakker (g, kg, ml, l, stk)."""
    text = text.lower()

    # multipack: 9x / 9 pack / 9 stk / 9pk
    pack_match = re.search(r'(\d+)\s*(?:x|pack|stk|pk)', text)
    antall = int(pack_match.group(1)) if pack_match else 1

    # vekt i gram/ml
    weight_match = re.search(r'(\d{2,4})\s*(g|ml)', text)
    if weight_match:
        vekt = int(weight_match.group(1))
        enhet = weight_match.group(2)
        if enhet == "ml":
            vekt = vekt  # eventuelt 1:1 med gram
    else:
        vekt = None

    # liter/kg deteksjon
    if not vekt:
        big_match = re.search(r'(\d+(?:[.,]\d+)?)\s*(l|kg)', text)
        if big_match:
            vekt = float(big_match.group(1).replace(',', '.')) * 1000

    # pris per kg
    price_per_kg = None
    kg_match = re.search(r'(\d+[.,]?\d*)\s*kr\s*/\s*kg', text)
    if kg_match:
        price_per_kg = kg_match.group(1).replace(',', '.')

    # kombiner
    total_vekt = vekt * antall if vekt else None
    mengde_str = (
        f"{antall}x{int(vekt)}g"
        if vekt and antall > 1 else
        (f"{vekt}g" if vekt else "Pr pk")
    )
    return mengde_str, total_vekt, price_per_kg
# ------------------------------------------------


def clean_data(raw):
    """Renser, normaliserer og dedupliserer produktdata."""
    merged = []
    for r in raw:
        if isinstance(r, list):
            merged.extend(r)
        elif isinstance(r, dict):
            merged.append(r)

    cleaned = []
    for it in merged:
        it["pris"] = normalize_price(it.get("pris", ""))
        categorize_item(it)

        text_blob = f"{it.get('produkt','')} {it.get('mengde','')} {it.get('pris','')}"
        mengde_str, total_vekt, price_per_kg = extract_weight_and_pack(text_blob)

        it["mengde"] = mengde_str
        if price_per_kg:
            it["pris_per_kg"] = f"{price_per_kg} kr/kg"
        if total_vekt:
            it["total_vekt_g"] = total_vekt

        cleaned.append(it)

    # Fjern søppel og eksakte duplikater først
    no_garbage = filter_garbage(remove_duplicates(cleaned))
    # Kjør deretter fuzzy deduplisering
    return deduplicate_fuzzy(no_garbage)
# ------------------------------------------------


def move_old_results():
    """Flytter gamle resultater til egen mappe."""
    gammel_dir = RESULT_DIR / "gammel"
    gammel_dir.mkdir(exist_ok=True)
    for f in RESULT_DIR.glob("*.json"):
        try:
            shutil.move(str(f), str(gammel_dir / f.name))
            print(f"📂 Flyttet gammel fil: {f.name}")
        except Exception as e:
            print(f"⚠️ Kunne ikke flytte {f.name}: {e}")


def safe_read_with_ai(image_path, store, retries=5):
    """Robust lesing via GPT med retry ved rate limit."""
    for i in range(retries):
        try:
            return read_with_ai(image_path, store)
        except RateLimitError:
            time.sleep(5 * (i + 1))
        except Exception as e:
            print(f"⚠️ Feil ved lesing {image_path}: {e}")
            break
    return ([], [])


def split_image(image_path, store, segment_height=1200):
    """Fallback segmentering dersom auto ikke finner noe."""
    img = cv2.imread(image_path)
    if img is None:
        return []
    h, w = img.shape[:2]
    segs = []
    for y in range(0, h, segment_height):
        part = img[y:y + segment_height, :]
        out = CHUNK_DIR / f"{store}_seg_{y}.png"
        cv2.imwrite(str(out), part)
        segs.append(str(out))
    return segs


def segment_image_auto(img_path):
    """Deler opp bilde automatisk i produktblokker."""
    import numpy as np
    img = cv2.imread(img_path)
    if img is None:
        return []
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    _, thresh = cv2.threshold(gray, 200, 255, cv2.THRESH_BINARY_INV)
    kernel = cv2.getStructuringElement(cv2.MORPH_RECT, (25, 25))
    dilated = cv2.dilate(thresh, kernel, iterations=3)
    contours, _ = cv2.findContours(dilated, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    rects = [
        (x, y, w, h)
        for (x, y, w, h) in [cv2.boundingRect(c) for c in contours]
        if w * h > 90000
    ]
    rects.sort(key=lambda r: (r[1], r[0]))
    out_files = []
    base = Path(img_path).stem
    for i, (x, y, w, h) in enumerate(rects):
        seg = img[y:y + h, x:x + w]
        p = CHUNK_DIR / f"{base}_block_{i}.png"
        cv2.imwrite(str(p), seg)
        out_files.append(str(p))
    return out_files or [img_path]
# ------------------------------------------------


def main():
    print("🚀 Starter split_and_read.py ...")
    move_old_results()

    for store_dir in EGEN_AVIS_DIR.iterdir():
        if not store_dir.is_dir():
            continue

        store_name = store_dir.name
        for date_dir in store_dir.iterdir():
            if not date_dir.is_dir():
                continue

            print(f"\n🧩 Leser {store_name} {date_dir.name} ...")
            png_files = sorted(date_dir.glob("part_*.png"))
            if not png_files:
                print(f"⚠️ Ingen part_*.png i {date_dir}")
                continue

            valid, reject = [], []

            for img_path in png_files:
                segs = segment_image_auto(str(img_path))
                if len(segs) <= 1:
                    segs = split_image(str(img_path), store_name)
                print(f"📸 {Path(img_path).name}: {len(segs)} segmenter")

                for s in segs:
                    v, r = safe_read_with_ai(s, store_name)
                    valid += v
                    reject += r
                    try:
                        os.remove(s)
                    except:
                        pass

            cleaned = clean_data(valid)
            out_json = RESULT_DIR / f"{store_name}_{date_dir.name.replace('-', '')}.json"
            json.dump(cleaned, open(out_json, "w", encoding="utf-8"), ensure_ascii=False, indent=2)

            if reject:
                rej = REJECT_DIR / f"{store_name}_{date_dir.name.replace('-', '')}_rejects.json"
                json.dump(reject, open(rej, "w", encoding="utf-8"), ensure_ascii=False, indent=2)

            print(f"✅ Ferdig: {store_name} {date_dir.name} ({len(cleaned)} produkter)")

    print("\n🎉 Split-and-read ferdig for alle butikker!")
    from ai_reader import TOTAL_TOKENS
    total_input = TOTAL_TOKENS["input"]
    total_output = TOTAL_TOKENS["output"]
    cost = (total_input * 0.005 + total_output * 0.015) / 1000
    print(f"\n💰 Total GPT-bruk: {total_input+total_output} tokens "
          f"(≈ ${cost:.3f} / ca {cost*11:.2f} NOK)")


if __name__ == "__main__":
    main()
