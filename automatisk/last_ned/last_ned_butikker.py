from bs4 import BeautifulSoup
import json, os, requests
from time import sleep

# ------------------------------------------------------------
# BRUK:
# & "C:\Users\sigur\AppData\Local\Programs\Python\Python312\python.exe" "D:\VSCode\SteelTilbud\automatisk\last_ned_butikker.py"
# ------------------------------------------------------------

# === STIER ===
base_dir = os.path.dirname(os.path.abspath(__file__))      # automatisk/
root_dir = os.path.dirname(base_dir)                       # SteelTilbud/
html_path = os.path.join(base_dir, "mattilbud.html")
json_path = os.path.join(base_dir, "butikker.json")
download_dir = os.path.join(root_dir, "butikk_html")       # lagrer her

os.makedirs(download_dir, exist_ok=True)

# ------------------------------------------------------------
# 🧹 TRINN 0: Fjern gamle HTML-filer før ny nedlasting
# ------------------------------------------------------------
gamle_filer = [f for f in os.listdir(download_dir) if f.lower().endswith(".html")]
if gamle_filer:
    for fil in gamle_filer:
        try:
            os.remove(os.path.join(download_dir, fil))
            print(f"🗑️  Fjernet gammel fil: {fil}")
        except Exception as e:
            print(f"⚠️  Kunne ikke fjerne {fil}: {e}")
else:
    print("📁 Ingen gamle HTML-filer å fjerne.")

# === BUTIKKER SOM SKAL BEHOLDES ===
tillat_butikker = [
    "Bunnpris", "Kiwi", "REMA 1000",
    "Coop Extra", "Coop Prix", "Meny", "Spar"
]

# === TRINN 1: Parse HTML ===
with open(html_path, "r", encoding="utf-8") as f:
    html = f.read()

soup = BeautifulSoup(html, "html.parser")

data = []
for li in soup.find_all("li"):
    a = li.find("a")
    img = li.find("img")
    h2 = li.find("h2")
    if a and img and h2:
        butikk_navn = h2.text.strip()
        # hopp over butikker som ikke er i listen
        if butikk_navn.lower() not in [b.lower() for b in tillat_butikker]:
            continue

        logo_url = img["src"]
        if not logo_url.startswith("http"):
            logo_url = "https://mattilbud.no" + logo_url.lstrip(".")
        data.append({
            "butikk": butikk_navn,
            "url": a["href"],
            "logo": logo_url
        })

with open(json_path, "w", encoding="utf-8") as f:
    json.dump(data, f, ensure_ascii=False, indent=4)

print(f"[OK] Lagret {len(data)} butikker → {json_path}")

# === TRINN 2: Last ned HTML for hver butikk ===
for i, b in enumerate(data, start=1):
    url = b["url"]
    navn = b["butikk"].replace(" ", "_").replace("/", "_")
    output_file = os.path.join(download_dir, f"{navn}.html")

    try:
        r = requests.get(url, headers={"User-Agent": "Mozilla/5.0"})
        if r.status_code == 200:
            with open(output_file, "w", encoding="utf-8") as f:
                f.write(r.text)
            print(f"[{i}/{len(data)}] OK – {navn}.html lagret")
        else:
            print(f"[{i}/{len(data)}] HTTP {r.status_code} for {navn}")
    except Exception as e:
        print(f"[{i}/{len(data)}] FEIL for {navn}: {e}")
    sleep(1)

print("\n✅ FERDIG! Nedlastet HTML for kun utvalgte butikker i:", download_dir)
