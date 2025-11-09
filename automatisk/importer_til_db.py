#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
importer_til_db.py – Leser OCR-resultater (JSON) og legger dem inn i
både lokal PostgreSQL (mattilbud) og Render (steeltilbud_db),
uten duplikater og med prislogg i pris_historikk.
"""

import os
import re
import json
import psycopg2
from datetime import date, timedelta

# --- KONFIG ---
LOCAL_DB = {
    "dbname": "mattilbud",
    "user": "postgres",
    "password": "flniqvdoyoxdh",
    "host": "localhost",
    "port": 5432,
}

RENDER_DB_URL = (
    "postgresql://steeltilbud_db_user:ib1ThceuXpbNL2XyiEi0FGqnGkcn05T4"
    "@dpg-d418leodl3ps73ckcc4g-a.frankfurt-postgres.render.com/steeltilbud_db"
)

RESULT_DIR = r"D:\VSCode\SteelTilbud\resultater"


# --- DB-TILKOBLINGER ---
def connect_db(conf, label):
    try:
        conn = psycopg2.connect(**conf) if isinstance(conf, dict) else psycopg2.connect(conf, sslmode="require")
        print(f"✅ Koblet til {label} database.")
        return conn, conn.cursor()
    except Exception as e:
        print(f"⚠️ Kunne ikke koble til {label}: {e}")
        return None, None


conn_local, cur_local = connect_db(LOCAL_DB, "Lokal")
conn_render, cur_render = connect_db(RENDER_DB_URL, "Render")


# --- HJELPEFUNKSJONER ---
def get_or_create(cur, conn, table, column, value):
    if not value:
        value = "Ukjent"
    cur.execute(f"SELECT id FROM {table} WHERE {column} = %s", (value,))
    row = cur.fetchone()
    if row:
        return row[0]
    cur.execute(f"INSERT INTO {table} ({column}) VALUES (%s) RETURNING id", (value,))
    conn.commit()
    return cur.fetchone()[0]


def safe_float(v):
    """Forsøk å trekke ut et tall fra en prisstreng (inkl. '2 for 50')."""
    if not v:
        return None
    v = (
        str(v)
        .lower()
        .replace(",", ".")
        .replace("kr", "")
        .replace(",-", "")
        .replace(".-", "")
        .strip()
    )
    if "for" in v:
        parts = re.findall(r"[\d.]+", v)
        if parts:
            return float(parts[-1])
        return None
    try:
        return float(re.findall(r"[\d.]+", v)[0])
    except Exception:
        return None


def parse_mengde_og_enhet(mengde_raw):
    """Ekstraherer tall og enhet fra tekst (inkl. dl-konvertering)."""
    mengde_raw = str(mengde_raw or "").lower().strip()
    match = re.search(r"([\d,.]+)\s*(kg|g|l|ml|dl|stk)?", mengde_raw)
    if match:
        mengde = safe_float(match.group(1))
        enhet = match.group(2) or ""

        # Konverter dl → l for konsistens
        if enhet == "dl":
            mengde = mengde / 10
            enhet = "l"
    elif "for" in mengde_raw:
        mengde, enhet = None, "kampanje"
    else:
        mengde, enhet = None, ""
    return mengde, enhet



# --- ARKIVERING AV FORRIGE UKE ---
def arkiver_forrige_uke(cur, conn, label):
    """Flytter alt fra forrige uke fra produkter → pris_historikk."""
    i_dag = date.today()
    forrige_søndag = i_dag - timedelta(days=i_dag.weekday() + 1)
    forrige_lørdag = forrige_søndag + timedelta(days=6)

    print(f"\n📦 Arkiverer produkter fra {forrige_søndag} til {forrige_lørdag} ({label})...")

    try:
        cur.execute("""
            INSERT INTO pris_historikk (
                produkt_id, butikk_id, pris, mengde, enhet,
                pris_per_enhet, pris_per_enhet_enhet, rabatt,
                kilde_fil, gyldig_fra, gyldig_til
            )
            SELECT 
                produkt_id, butikk_id, pris, mengde, enhet,
                pris_per_enhet, pris_per_enhet_enhet, rabatt,
                kilde_fil, dato, dato
            FROM produkter
            WHERE dato BETWEEN %s AND %s
            ON CONFLICT (produkt_id, butikk_id, gyldig_fra, pris) DO NOTHING;
        """, (forrige_søndag, forrige_lørdag))
        conn.commit()

        cur.execute("DELETE FROM produkter WHERE dato BETWEEN %s AND %s;", (forrige_søndag, forrige_lørdag))
        conn.commit()

        print(f"✅ Arkivering fullført for {label}.\n")
    except Exception as e:
        conn.rollback()
        print(f"⚠️ Feil ved arkivering for {label}: {e}")


# --- HOVEDIMPORT ---
def import_to_one(cur, conn, datafile, item):
    """Setter inn eller oppdaterer ett produkt og logger prisendringer."""
    butikk_navn = (item.get("butikk") or "Ukjent").replace("_", " ").strip().title()
    kategori_navn = (item.get("kategori") or "Annet").strip().title()

    # Normalisering av kategorier
    aliaser = {
        "Frossenvarer": "Frossenmat", "Frysevarer": "Frossenmat",
        "Frukt Og Grønt": "Frukt og grønt", "Frukt/Grønt": "Frukt og grønt",
        "Grønnsaker": "Frukt og grønt", "Frukt": "Frukt og grønt",
        "Bakervarer": "Bakst", "Bakevarer": "Bakst", "Bakverk": "Bakst",
        "Kake": "Bakst", "Kaker": "Bakst", "Drikkevarer": "Drikke",
        "Krydder/Saus": "Krydder", "Sauser": "Krydder",
        "Personlig Pleie": "Hygiene", "Hudpleie": "Hygiene",
        "Matvarer": "Dagligvarer", "Delikatesse": "Ferdigmat",
    }
    kategori_navn = aliaser.get(kategori_navn, kategori_navn)

    sjeldne = {
        "Planter", "Blomster", "Bøker", "Kalender", "Elektronikk",
        "Spill", "Klær", "Kjøkkenutstyr", "Kjøkken", "Plaster"
    }
    if kategori_navn in sjeldne:
        kategori_navn = "Annet"

    produktnavn = (item.get("produkt") or "").strip()
    if not produktnavn:
        return

    butikk_id = get_or_create(cur, conn, "butikk", "navn", butikk_navn)
    kategori_id = get_or_create(cur, conn, "kategori", "navn", kategori_navn)

    # Hent eller opprett produkt
    cur.execute("SELECT id FROM produkt WHERE navn = %s", (produktnavn,))
    row = cur.fetchone()
    if row:
        produkt_id = row[0]
    else:
        cur.execute("INSERT INTO produkt (navn, kategori_id) VALUES (%s, %s) RETURNING id", (produktnavn, kategori_id))
        produkt_id = cur.fetchone()[0]
        conn.commit()

    pris = safe_float(item.get("pris"))
    mengde_raw = item.get("mengde", "")
    rabatt = (item.get("rabatt") or "").strip()
    mengde, enhet = parse_mengde_og_enhet(mengde_raw)

    pris_per_enhet = None
    pris_per_enhet_enhet = None
    if pris and mengde and enhet in ["kg", "g", "l", "ml"]:
        faktor = 1000 if enhet in ["g", "ml"] else 1
        pris_per_enhet = round(pris / (mengde / faktor), 2)
        pris_per_enhet_enhet = "kr/kg" if enhet in ["g", "kg"] else "kr/l"

    # --- Ny: pris_per_kg og total_vekt_g ---
    pris_per_kg = item.get("pris_per_kg")
    if pris_per_kg:
        pris_per_kg = float(str(pris_per_kg).replace("kr/kg", "").replace(",", ".").strip() or 0)

    total_vekt_g = item.get("total_vekt_g")
    if total_vekt_g:
        try:
            total_vekt_g = float(total_vekt_g)
        except:
            total_vekt_g = None

    # --- Logg pris for dagen ---
    cur.execute("""
        INSERT INTO pris_historikk (
            produkt_id, butikk_id, pris, mengde, enhet,
            pris_per_enhet, pris_per_enhet_enhet, rabatt,
            pris_per_kg, total_vekt_g,
            kilde_fil, gyldig_fra, gyldig_til
        )
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, CURRENT_DATE, CURRENT_DATE)
        ON CONFLICT (produkt_id, butikk_id, gyldig_fra, pris) DO NOTHING;
    """, (
        produkt_id, butikk_id, pris, mengde, enhet,
        pris_per_enhet, pris_per_enhet_enhet, rabatt,
        pris_per_kg, total_vekt_g,
        datafile
    ))
    conn.commit()

    # --- Oppdater produkter-tabellen ---
    cur.execute("""
        INSERT INTO produkter (
            produkt_id, butikk_id, pris, mengde, enhet, pris_per_enhet,
            pris_per_enhet_enhet, rabatt, kilde_fil, dato
        )
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, CURRENT_DATE)
        ON CONFLICT (produkt_id, butikk_id) DO UPDATE
        SET pris = EXCLUDED.pris,
            mengde = EXCLUDED.mengde,
            enhet = EXCLUDED.enhet,
            pris_per_enhet = EXCLUDED.pris_per_enhet,
            pris_per_enhet_enhet = EXCLUDED.pris_per_enhet_enhet,
            rabatt = EXCLUDED.rabatt,
            kilde_fil = EXCLUDED.kilde_fil,
            dato = CURRENT_DATE;
    """, (
        produkt_id, butikk_id, pris, mengde, enhet,
        pris_per_enhet, pris_per_enhet_enhet, rabatt, datafile
    ))
    conn.commit()


# --- HOVEDLØP ---
if cur_local: arkiver_forrige_uke(cur_local, conn_local, "Lokal")
if cur_render: arkiver_forrige_uke(cur_render, conn_render, "Render")

for file in os.listdir(RESULT_DIR):
    if not file.lower().endswith(".json"):
        continue
    path = os.path.join(RESULT_DIR, file)
    print(f"📄 Leser {path}")

    try:
        data = json.load(open(path, encoding="utf-8"))
    except Exception as e:
        print(f"⚠️ Feil ved lesing av {file}: {e}")
        continue

    for item in data:
        for cur, conn, label in [
            (cur_local, conn_local, "Lokal"),
            (cur_render, conn_render, "Render"),
        ]:
            if cur is None:
                continue
            try:
                import_to_one(cur, conn, file, item)
                conn.commit()
            except psycopg2.Error as e:
                conn.rollback()
                print(f"⚠️ [{label}] Feil ved '{item.get('produkt')}': {e.pgerror}")
            except Exception as e:
                conn.rollback()
                print(f"⚠️ [{label}] Uventet feil ved '{item.get('produkt')}': {e}")

print("\n🎉 Ferdig importert til begge databaser!")
if cur_local: cur_local.close()
if conn_local: conn_local.close()
if cur_render: cur_render.close()
if conn_render: conn_render.close()
