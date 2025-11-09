#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Kjører alle butikk-skriptene og arkiverer tidligere PDF-er først.

- Flytter alle eksisterende *_avis_*.pdf fra kundeaviser/Egen_avis/ til kundeaviser/Egen_avis/gammel/
- Kjører følgende skript sekvensielt:
  bunnpris.py, coop_extra.py, coop_prix.py, kiwi.py, meny.py, rema.py, spar.py

Bruk:
  python butikk_henting/run_all.py         # arkiver + kjør alle
  python butikk_henting/run_all.py --archive-only   # kun arkiver
"""

from __future__ import annotations
import sys
import subprocess
import shutil
import time
from pathlib import Path
import argparse

REPO_ROOT = Path(__file__).resolve().parents[1]
EGEN_AVIS_DIR = REPO_ROOT / "kundeaviser" / "Egen_avis"
EGEN_AVIS_GAMMEL = EGEN_AVIS_DIR / "gammel"

SCRIPTS = [
    "bunnpris.py",
    "coop_extra.py",
    "coop_prix.py",
    "kiwi.py",
    "meny.py",
    "rema.py",
    "spar.py",
]


def archive_existing_pdfs() -> int:
    EGEN_AVIS_GAMMEL.mkdir(parents=True, exist_ok=True)
    if not EGEN_AVIS_DIR.exists():
        print(f"⚠️ Fant ikke mappe: {EGEN_AVIS_DIR}")
        return 0

    moved = 0
    ts = time.strftime("%Y%m%d_%H%M%S")
    for pdf in sorted(EGEN_AVIS_DIR.glob("*_avis_*.pdf")):
        if pdf.is_dir():
            continue
        dest = EGEN_AVIS_GAMMEL / pdf.name
        # Hvis samme navn allerede finnes i 'gammel', legg til tidsstempel
        if dest.exists():
            dest = EGEN_AVIS_GAMMEL / f"{pdf.stem}__{ts}{pdf.suffix}"
        try:
            shutil.move(str(pdf), str(dest))
            moved += 1
        except Exception as e:
            print(f"❌ Klarte ikke å flytte {pdf.name}: {e}")
    print(f"📦 Arkiverte {moved} tidligere PDF(er) til {EGEN_AVIS_GAMMEL}")
    return moved


def run(script: str) -> None:
    path = Path(__file__).with_name(script)
    if not path.exists():
        print(f"❌ Finner ikke skript: {path}")
        sys.exit(1)
    print(f"\n🚀 Kjører {path.name} ...")
    try:
        subprocess.run([sys.executable, str(path)], check=True)
        print(f"✅ Ferdig: {path.name}")
    except subprocess.CalledProcessError as e:
        print(f"❌ Feil i {path.name}: {e}")
        sys.exit(e.returncode or 1)


def main():
    parser = argparse.ArgumentParser(description="Kjør alle butikk-skript og arkiver gamle PDF-er")
    parser.add_argument("--archive-only", action="store_true", help="Bare flytt gamle PDF-er, ikke kjør skriptene")
    args = parser.parse_args()

    archive_existing_pdfs()
    if args.archive_only:
        return

    for s in SCRIPTS:
        run(s)


if __name__ == "__main__":
    main()
