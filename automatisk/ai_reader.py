#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
ai_reader.py (v4.1)
Leser segmenter fra kundeaviser ved hjelp av GPT-4o Vision.

- Forbehandler bilder (lys/kontrast)
- Sender segmenter til GPT-4o
- Validerer resultater
- Filtrerer duplikater og støy
"""

import os, re, cv2, json, base64, numpy as np
from pathlib import Path
from pdf2image import convert_from_path
from datetime import datetime
from openai import OpenAI
from auto_validate import detect_mismatch

client = OpenAI()

VALID_CATEGORIES = {
    "Meieri": 1,
    "Snacks": 2,
    "Drikke": 3,
    "Kjøtt": 4,
    "Bakst": 55,           # bruker din DB-ID for "Bakst"
    "Tørrvarer": 9,
    "Frossenmat": 48,
    "Frukt og grønt": 68,
    "Pålegg": 13,
    "Hygiene": 29,
    "Husholdning": 20,
    "Annet": 23
}


# --- Token-tracking ---
TOTAL_TOKENS = {"input": 0, "output": 0}

def log_tokens(usage):
    if not usage:
        return
    input_t = usage.get("prompt_tokens", 0)
    output_t = usage.get("completion_tokens", 0)
    TOTAL_TOKENS["input"] += input_t
    TOTAL_TOKENS["output"] += output_t
    print(f"🧮 Tokens brukt denne forespørselen: {input_t + output_t} "
          f"(prompt: {input_t}, completion: {output_t})")


# ------------------------------------------------------------
# 🖼️ Forbehandling av bilder
# ------------------------------------------------------------
def preprocess_image(image_path):
    """Forbedrer lys og kontrast. Hvis PDF: konverter første side til PNG."""
    if not os.path.exists(image_path):
        print(f"⚠️ Fant ikke bildefil: {image_path}")
        return image_path

    if image_path.lower().endswith(".pdf"):
        pages = convert_from_path(image_path, dpi=300)
        if not pages:
            print(f"⚠️ Ingen sider i PDF: {image_path}")
            return image_path
        new_path = image_path.replace(".pdf", "_page1.png")
        pages[0].save(new_path, "PNG")
        image_path = new_path

    img = cv2.imread(image_path)
    if img is None:
        print(f"⚠️ Kunne ikke lese: {image_path}")
        return image_path

    # Forsterk kontrast og lys
    img = cv2.resize(img, None, fx=1.5, fy=1.5, interpolation=cv2.INTER_CUBIC)
    lab = cv2.cvtColor(img, cv2.COLOR_BGR2LAB)
    l, a, b = cv2.split(lab)
    l = cv2.equalizeHist(l)
    enhanced = cv2.merge((l, a, b))
    enhanced = cv2.cvtColor(enhanced, cv2.COLOR_LAB2BGR)

    new_path = str(Path(image_path).with_name(Path(image_path).stem + "_prep.png"))
    cv2.imwrite(new_path, enhanced)
    print(f"✨ Forbedret kontrast for {os.path.basename(image_path)}")
    return new_path


# ------------------------------------------------------------
# 🧮 Hjelpefunksjoner
# ------------------------------------------------------------
def normalize_price(p):
    """Standardiserer prisuttrykk som '3for2', '2x40' osv."""
    if not p:
        return ""
    p = str(p).strip().replace("−", "-").replace(",", ".").lower()
    p = re.sub(r"\s+", " ", p)
    p = re.sub(r"(\d)\s*for\s*(\d)", r"\1 for \2", p)
    p = re.sub(r"(\d)\s*x\s*(\d+)", r"\1 x \2", p)
    return p


def remove_duplicates(items):
    """Fjerner eksakte duplikater (fuzzy håndteres i split_and_read)."""
    seen = set()
    unique = []
    for item in items:
        key = (
            item.get("butikk", "").lower(),
            item.get("produkt", "").strip().lower(),
            item.get("pris", "").strip().lower(),
        )
        if key not in seen:
            unique.append(item)
            seen.add(key)
    return unique


def filter_garbage(items):
    """Fjerner meningsløse linjer og støy."""
    filtered = []
    for i in items:
        produkt = i.get("produkt", "").strip().lower()
        pris = i.get("pris", "").strip().lower()

        if not produkt and not pris:
            continue
        if re.fullmatch(r"^\d+(\.\d+)?$", produkt):
            continue
        if any(x in produkt for x in ["rosa sløyfe", "gbp", "ln", "trykk", "kampanje"]):
            continue
        filtered.append(i)
    return filtered


CATEGORY_ALIASES = {
    "meieri": "Meieri",
    "snacks": "Snacks",
    "godteri": "Snacks",
    "søtsaker": "Snacks",
    "sjokolade": "Snacks",
    "iskrem": "Snacks",

    "drikke": "Drikke",
    "drikkevarer": "Drikke",
    "kaffe": "Drikke",

    "kjøtt": "Kjøtt",
    "delikatesse": "Kjøtt",  # kan evt. settes til "Annet" hos deg

    "tørrvarer": "Tørrvarer",
    "krydder": "Tørrvarer",
    "krydder/saus": "Tørrvarer",
    "sauser": "Tørrvarer",
    "dressing": "Tørrvarer",
    "pasta": "Tørrvarer",
    "ris": "Tørrvarer",
    "hermetikk": "Tørrvarer",
    "matolje": "Tørrvarer",
    "frokostblanding": "Tørrvarer",
    "frokost": "Tørrvarer",
    "taco": "Tørrvarer",

    "fisk": "Fisk",
    "sjømat": "Fisk",

    "pålegg": "Pålegg",
    "egg": "Pålegg",

    "hygiene": "Hygiene",
    "personlig pleie": "Hygiene",
    "hudpleie": "Hygiene",
    "plaster": "Hygiene",

    "husholdning": "Husholdning",
    "rengjøring": "Husholdning",

    "frossenvarer": "Frossenmat",
    "frysevarer": "Frossenmat",
    "frossenmat": "Frossenmat",
    "ferdigmat": "Frossenmat",
    "ferdigretter": "Frossenmat",

    "bakst": "Bakst",
    "baking": "Bakst",
    "bakervarer": "Bakst",
    "bakevarer": "Bakst",
    "bakverk": "Bakst",
    "brød": "Bakst",
    "kaker": "Bakst",
    "kake": "Bakst",

    "frukt/grønt": "Frukt og grønt",
    "frukt og grønt": "Frukt og grønt",
    "frukt og grønnsaker": "Frukt og grønt",
    "frukt": "Frukt og grønt",
    "grønnsaker": "Frukt og grønt",

    "annet": "Annet",
    "diverse": "Annet",
    "hjem": "Annet",
    "kjøkken": "Annet",
    "kjøkkenutstyr": "Annet",
    "elektronikk": "Annet",
    "dyremat": "Annet",
    "blomster": "Annet",
    "planter": "Annet",
    "bøker": "Annet",
    "spill": "Annet",
    "kalender": "Annet",
    "barnemat": "Annet",
    "matvarer": "Annet",
    "dagligvarer": "Annet",
}

def _has_any(text: str, words) -> bool:
    """True hvis noen av ordene finnes som hele ord (word boundary)."""
    return any(re.search(rf"\b{re.escape(w)}\b", text) for w in words)

def _norm_cat(cat: str):
    if not cat:
        return None
    c = CATEGORY_ALIASES.get(cat.strip().lower())
    return c if c in VALID_CATEGORIES else None

def categorize_item(item):
    """Klassifiserer til én av de 13 hovedkategoriene. Fallback = Annet."""
    # 1) Hvis GPT allerede satte en forståelig kategori – respekter den
    gpt_cat = _norm_cat(item.get("kategori", ""))
    if gpt_cat:
        item["kategori"] = gpt_cat
        item["kategori_id"] = VALID_CATEGORIES[gpt_cat]
        return item

    # 2) Ellers, regelbasert fallback på produktnavn
    name = (item.get("produkt") or "").lower()

    # — Snacks (sjokolade, godteri, chips, iskrem) —
    if _has_any(name, [
        "smågodt","godteri","gummies","lakris","drops","konfekt",
        "sjokolade","freia","nidar","mars","kvikk lunsj","stratos",
        "chips","potetgull","kims","cheez doodles",
        "iskrem","diplom-is","hennig-olsen","pint","is"
    ]):
        cat = "Snacks"

    # — Meieri —
    elif _has_any(name, [
        "melk","lettmelk","skummet","yoghurt","ost","norvegia","jarlsberg",
        "prim","smør","margarin","rømme","kefir","fløte","kesam","cottage cheese","tine","synnøve"
    ]):
        cat = "Meieri"

    # — Drikke —
    elif _has_any(name, [
        "brus","cola","pepsi","fanta","solo","sprite","red bull","battery","monster","burn",
        "juice","eplejuice","appelsinjuice","saft","iste","vann","mineralvann","øl","kaffe","kakao","energidrikk"
    ]):
        cat = "Drikke"

    # — Kjøtt —
    elif _has_any(name, [
        "kjøtt","kjøttdeig","karbonade","svin","storfe","okse",
        "kylling","kalkun","bacon","skinke","pølse","nuggets","kjøttkaker","farser"
    ]):
        cat = "Kjøtt"

    # — Fisk (merk: “makrell i tomat” → Pålegg) —
    elif "makrell i tomat" in name:
        cat = "Pålegg"
    elif _has_any(name, [
        "fisk","laks","ørret","torsk","sei","makrell","sild","fiskekaker","fiskepinner","reker"
    ]):
        cat = "Fisk"

    # — Pålegg (inkl. egg og typiske brød-pålegg) —
    elif _has_any(name, [
        "pålegg","leverpostei","syltetøy","nugatti","prim","kaviar","majones",
        "smøreost","ostepålegg","peanøttsmør","egg","makrell i tomat"
    ]):
        cat = "Pålegg"

    # — Frossenmat (NB: iskrem allerede tatt som Snacks) —
    elif _has_any(name, [
        "frossen","fryst","grandiosa","big one","dr. oetker","pizza","wok","pytt","pommes","frossen grønnsaker","fiskegrateng"
    ]):
        cat = "Frossenmat"

    # — Bakst —
    elif _has_any(name, [
        "brød","loff","baguette","boller","rundstykker","kneipp",
        "bakst","bake","kake","muffins","croissant","bakverk"
    ]):
        cat = "Bakst"

    # — Tørrvarer —
    elif _has_any(name, [
        "pasta","spaghetti","fusilli","penne","ris","mel","havre","gryn","knekkebrød",
        "krydder","pepper","salt","urter","saus","sauspose","taco","tortilla","salsa","hermetikk",
        "olje","solsikkeolje","olivenolje","dressing","frokostblanding","corn flakes","müsli"
    ]):
        cat = "Tørrvarer"

    # — Hygiene —
    elif _has_any(name, [
        "såpe","sjampo","shampoo","balsam","tannkrem","tannbørste","deo","deodorant",
        "plaster","bind","bleier","antibac","hånddesinfeksjon","toalettpapir","tørkerull","servietter","bomull"
    ]):
        cat = "Hygiene"

    # — Husholdning —
    elif _has_any(name, [
        "vask","vaskemiddel","oppvask","oppvaskmiddel","klut","svamp","rengjøring","rens",
        "avkalker","skyllemiddel","avløp","avfall","søppelsekk","aluminiumsfolie","plastfolie","zip","pose"
    ]):
        cat = "Husholdning"

    else:
        cat = "Annet"

    # Sikker slutt-normalisering og ID
    if cat not in VALID_CATEGORIES:
        cat = "Annet"
    item["kategori"] = cat
    item["kategori_id"] = VALID_CATEGORIES[cat]
    return item



# ------------------------------------------------------------
# 🤖 Hovedfunksjon: Les bilde med GPT-4o
# ------------------------------------------------------------
def read_with_ai(image_path: str, store: str, category: str = ""):
    """Les kundeavis-bilde med GPT-4o og returner JSON-liste."""
    image_path = preprocess_image(image_path)
    with open(image_path, "rb") as f:
        b64 = base64.b64encode(f.read()).decode()

    prompt = f"""
    Du ser et utsnitt fra kundeavisen til {store}.
    Finn ALLE produkter med pris eller kampanje på bildet.

    Returner KUN en gyldig JSON-liste slik:
    [
      {{
        "butikk": "{store}",
        "produkt": "Tine Norvegia 500g",
        "pris": "3 for 100" eller "29.90",
        "mengde": "500g" eller "9x170g" osv.,
        "kategori": "Meieri" eller "Frukt/Grønt" osv.,
        "pris_per_kg": "71.24 kr/kg" hvis oppgitt, ellers tom streng,
        "total_vekt_g": 1700 hvis oppgitt, ellers null
      }}
    ]

    Regler:
    - Behold nøyaktig tekst for tilbud som "3 for 2", "2 for 30kr", "Alt til 10".
    - Ikke ta med produkter uten pris eller kampanje.
    - Slå sammen grupper som "Et utvalg proteinprodukter" til ett produktnavn.
    - Bruk enhet (g, kg, ml, l, stk) om mulig.
    - Ta med multipakker som "4x0.25L" eller "9x170g".
    - Hvis "kr/kg" eller "kr/l" står oppgitt, ta det med.
    - Ingen tekst utenfor JSON.
    """

    resp = client.chat.completions.create(
        model="gpt-4o",
        temperature=0,
        max_tokens=2000,
        messages=[
            {"role": "system",
             "content": "Du er en ekspert på å lese norske kundeaviser og tolke tilbud nøyaktig."},
            {"role": "user",
             "content": [
                 {"type": "text", "text": prompt},
                 {"type": "image_url", "image_url": {"url": f"data:image/png;base64,{b64}"}}
             ]},
        ],
    )

    # 🔢 Logg tokenbruk
    log_tokens(getattr(resp, "usage", None))

    # ---------------- PARSING ----------------
    txt = resp.choices[0].message.content
    data = []
    try:
        match = re.search(r"\[.*\]", txt, re.DOTALL)
        if match:
            data = json.loads(match.group(0))
            # Sikre at alle felt finnes
            for d in data:
                if not isinstance(d, dict):
                    continue
                d.setdefault("butikk", store)
                d.setdefault("produkt", "")
                d.setdefault("pris", "")
                d.setdefault("mengde", "")
                d.setdefault("pris_per_kg", "")
                d.setdefault("total_vekt_g", None)
                d = categorize_item(d)
                d["pris"] = normalize_price(d["pris"])
    except Exception as e:
        print(f"⚠️ Kunne ikke parse JSON fra GPT: {e}")

    if not isinstance(data, list):
        print(f"⚠️ Ugyldig JSON-format for {store}. Innhold: {txt[:120]}...")
        data = []

    clean, rejected = [], []
    for d in data:
        if not isinstance(d, dict):
            continue
        d["pris"] = normalize_price(d.get("pris", ""))
        d = categorize_item(d)
        reason = detect_mismatch(d)
        if reason:
            d["reject_reason"] = reason
            rejected.append(d)
        else:
            clean.append(d)

    # Filtrer bort tull
    clean = [
        i for i in clean
        if i.get("pris") and not re.search(r"-\d", i["pris"]) and any(c.isdigit() for c in i["pris"])
    ]

    print(f"✅ GPT leste {store}: {len(clean)} produkter, {len(rejected)} avvist. ({os.path.basename(image_path)})")
    return clean, rejected
