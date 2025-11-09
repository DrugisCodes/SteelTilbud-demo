#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Automatisk kjører alle butikkskript, etterfulgt av split_and_read og import til DB.

Krav oppfylt:
- Kjører alle Python-skript i "butikk_henting" unntatt run_all.py og main.py
- Kjører sekvensielt via subprocess, med tydelig progresjon og feilhåndtering
- Etter butikker: kjør split_and_read.py og så import-til-DB-skript
- Forventer at output-bilder havner i kundeaviser/Egen_avis/{store}/{YYYY-MM-DD}/

Bruk: kjør fra prosjekt-roten (D:/VSCode/SteelTilbud/):
  python automatisk/main.py
"""

from __future__ import annotations

import sys, os
import subprocess
from pathlib import Path
from typing import List, Tuple
import sys
sys.stdout.reconfigure(encoding='utf-8')

# Sørg for UTF-8 for alt output og alle subprocesser
os.environ["PYTHONIOENCODING"] = "utf-8"
os.environ["PYTHONUTF8"] = "1"
sys.stdout.reconfigure(encoding="utf-8")

REPO_ROOT = Path(__file__).resolve().parents[1]  # prosjekt-roten

PYTHON = sys.executable  # bruk samme Python som kjører scriptet (3.12)


def pretty_name(stem: str) -> str:
    return stem.replace("_", " ").upper()


def run_python_script(script_path: Path) -> Tuple[bool, str]:
    """Run a Python script and return (success, combined_output)."""
    try:
        env = os.environ.copy()
        env["PYTHONIOENCODING"] = "utf-8"
        env["PYTHONUTF8"] = "1"

        proc = subprocess.run(
            [PYTHON, str(script_path)],
            capture_output=True,
            text=True,
            cwd=str(REPO_ROOT),
            env=env,  # 👈 Sørger for UTF-8 i alle butikk-skript
        )
        output = (proc.stdout or "") + (proc.stderr or "")
        return proc.returncode == 0, output
    except Exception as e:
        return False, f"Exception: {e}"



def find_store_scripts(butikker_dir: Path) -> List[Path]:
    scripts = []
    for p in sorted(butikker_dir.glob("*.py")):
        if p.name.lower() in {"run_all.py", "main.py", "__init__.py"}:
            continue
        scripts.append(p)
    return scripts


def main() -> None:
    repo_root = REPO_ROOT
    butikker_dir = repo_root / "butikk_henting"
    auto_dir = repo_root / "automatisk"

    print("===========================================")
    print(" SteelTilbud – automatisk oppdatering")
    print("===========================================\n")

    successes: List[str] = []
    failures: List[str] = []

    # 1) Kjør alle butikkskript
    for script in find_store_scripts(butikker_dir):
        name = pretty_name(script.stem)
        print(f"📦 Running {name}...")
        ok, out = run_python_script(script)
        if ok:
            print(f"✅ {name} done.")
            successes.append(script.stem)
        else:
            print(f"❌ {name} failed.")
            if out:
                # vis siste 20 linjer for feilsøking
                tail = "\n".join(out.splitlines()[-20:])
                print(tail)
            failures.append(script.stem)

    # 2) split_and_read
    split_script = auto_dir / "split_and_read.py"
    if split_script.exists():
        print("🧩 Running split_and_read...")
        ok, out = run_python_script(split_script)
        if ok:
            print("✅ split_and_read complete.")
            successes.append("split_and_read")
        else:
            print("❌ split_and_read failed.")
            if out:
                print("\n".join(out.splitlines()[-20:]))
            failures.append("split_and_read")
    else:
        print("⚠️ split_and_read.py not found; skipping.")

    # 3) import to DB (handle both names)
    import_candidates = [auto_dir / "import_to_db.py", auto_dir / "importer_til_db.py"]
    import_script = next((p for p in import_candidates if p.exists()), None)
    if import_script is not None:
        print("💾 Importing to database...")
        ok, out = run_python_script(import_script)
        if ok:
            print("✅ import_to_db finished.")
            successes.append(import_script.stem)
        else:
            print("❌ import_to_db failed.")
            if out:
                print("\n".join(out.splitlines()[-20:]))
            failures.append(import_script.stem)
    else:
        print("⚠️ Import script not found (looked for import_to_db.py / importer_til_db.py). Skipping.")

    # 4) Oppsummering
    print("\n📊 Summary")
    if successes:
        print("  ✅ Completed:")
        for s in successes:
            print(f"   • {s}")
    if failures:
        print("  ❌ Failed:")
        for f in failures:
            print(f"   • {f}")

    if failures:
        print("\n⚠️ Done with some failures.")
        sys.exit(1)
    else:
        print("\n🎉 All steps completed successfully.")


if __name__ == "__main__":
    main()
