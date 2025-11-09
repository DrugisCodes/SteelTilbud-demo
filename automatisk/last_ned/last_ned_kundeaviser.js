// --------------------------------------------------
// 📰 Automatisk nedlasting av kundeaviser (PNG)
// --------------------------------------------------
// Kjør med:   node .\automatisk\last_ned_kundeaviser.js

import puppeteer from "puppeteer";
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";
import { dirname } from "path";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const inputFil = "D:/VSCode/SteelTilbud/automatisk/butikker.json";
const outputMappe = path.join(__dirname, "..", "kundeaviser");

const ønskedeButikker = [
  "Bunnpris",
  "KIWI",
  "REMA 1000",
  "Coop Extra",
  "Coop Prix",
  "SPAR",
  "MENY",
];

// --------------------------------------------------
// 🗂️ Opprett mappe hvis den ikke finnes
// --------------------------------------------------
if (!fs.existsSync(outputMappe)) fs.mkdirSync(outputMappe, { recursive: true });

// --------------------------------------------------
// 📋 Les inn butikkdata fra JSON og filtrer
// --------------------------------------------------
const butikker = JSON.parse(fs.readFileSync(inputFil, "utf8"))
  .filter(b => ønskedeButikker.includes(b.butikk));

// --------------------------------------------------
// 🚀 Hovedprogram
// --------------------------------------------------
(async () => {
  process.on("unhandledRejection", (reason) => {
    console.error("Unhandled Rejection:", reason);
  });
  process.on("uncaughtException", (err) => {
    console.error("Uncaught Exception:", err);
    process.exit(1);
  });

  // 🧹 Flytt gamle kundeaviser til /gammel før ny nedlasting
  const gammelMappe = path.join(outputMappe, "gammel");
  if (!fs.existsSync(gammelMappe)) fs.mkdirSync(gammelMappe, { recursive: true });

  const gamleFiler = fs.readdirSync(outputMappe)
    .filter(f => f.toLowerCase().endsWith(".png"));

  const dato = new Date().toISOString().split("T")[0].replace(/-/g, "");
  for (const fil of gamleFiler) {
    const fullPath = path.join(outputMappe, fil);
    const nyttNavn = fil.replace(".png", `_${dato}.png`);
    const dest = path.join(gammelMappe, nyttNavn);

    try {
      fs.renameSync(fullPath, dest);
      console.log(`📦 Flyttet gammel kundeavis: ${fil} → ${nyttNavn}`);
    } catch (err) {
      console.error(`⚠️ Kunne ikke flytte ${fil}:`, err.message);
    }
  }

  const browser = await puppeteer.launch({
    headless: true,
    defaultViewport: { width: 1600, height: 1800 },
  });

  for (const butikk of butikker) {
    const navn = butikk.butikk.replace(/[^a-zA-Z0-9æøåÆØÅ]/g, "_");
    const url = butikk.url;

    console.log(`\n📄 Laster kundeavis for: ${butikk.butikk}`);
    const page = await browser.newPage();

    try {
      await page.goto(url, { waitUntil: "domcontentloaded", timeout: 60000 });
      await new Promise(r => setTimeout(r, 4000));
      await autoScroll(page);

      const bildePath = path.join(outputMappe, `${navn}.png`);
      await page.screenshot({ path: bildePath, fullPage: true });

      console.log(`✅ Lagret bildet: ${bildePath}`);
    } catch (err) {
      console.error(`❌ Feil ved ${butikk.butikk}: ${err.message}`);
    } finally {
      await page.close();
    }
  }

  await browser.close();
  console.log("\n🎉 Ferdig med nedlasting av alle valgte kundeaviser!");
})();

async function autoScroll(page) {
  await page.evaluate(async () => {
    await new Promise((resolve) => {
      let totalHeight = 0;
      const distance = 800;
      const timer = setInterval(() => {
        window.scrollBy(0, distance);
        totalHeight += distance;
        if (totalHeight >= document.body.scrollHeight) {
          clearInterval(timer);
          resolve();
        }
      }, 400);
    });
  });
}
