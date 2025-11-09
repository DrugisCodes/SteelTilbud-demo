import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import cookieParser from "cookie-parser";
import helmet from "helmet";
import { requireCsrf } from "./middleware/csrf.js";
import authRoutes from "./routes/auth.js";
import favorittRoutes from "./routes/favoritter.js";
import db from "./db/index.js";

dotenv.config();

const app = express(); // ✅ må komme før app.get() brukes

// ------------------------------------------------------------
// 🔐 Middleware
// ------------------------------------------------------------
app.use(
  cors({
    origin: (origin, cb) => cb(null, true),
    methods: ["GET", "POST", "DELETE"],
    allowedHeaders: ["Content-Type"],
    credentials: true,
  })
);
app.use(express.json());
app.use(cookieParser());
app.use(helmet());

// ------------------------------------------------------------
// 1️⃣ HENT PRODUKTER
// ------------------------------------------------------------
app.get("/api/produkter", async (req, res) => {
  try {
    const result = await db.query(`
      SELECT 
        p.id,
        pr.navn AS produkt,
        b.navn AS butikk,
        k.navn AS kategori,
        p.pris,
        p.rabatt,
        p.mengde,
        p.enhet,
        p.pris_per_enhet,
        p.pris_per_enhet_enhet
      FROM produkter p
      JOIN produkt pr ON p.produkt_id = pr.id
      JOIN butikk b ON p.butikk_id = b.id
      LEFT JOIN kategori k ON pr.kategori_id = k.id
    `);
    res.json(result.rows);
  } catch (err) {
  console.error("DB error:", err.message);
  res.status(500).json({ error: "Database query failed", details: err.message });
}
});

// ------------------------------------------------------------
// 2️⃣ SØK-PRODUKTER
// ------------------------------------------------------------
app.get("/api/sok", async (req, res) => {
  const { butikk, kategori, produkt } = req.query;
  const where = [];
  const values = [];

  if (butikk) {
    values.push(`%${butikk}%`);
    where.push(`butikk ILIKE $${values.length}`);
  }
  if (kategori) {
    values.push(`%${kategori}%`);
    where.push(`kategori ILIKE $${values.length}`);
  }
  if (produkt) {
    values.push(`%${produkt}%`);
    where.push(`produkt ILIKE $${values.length}`);
  }

  const query = `
    SELECT 
      id, butikk, kategori, produkt, pris, mengde, enhet,
      pris_per_enhet, pris_per_enhet_enhet, dato
    FROM v_produktoversikt_full
    ${where.length ? "WHERE " + where.join(" AND ") : ""}
    ORDER BY dato DESC
  `;

  try {
    const result = await db.query(query, values);
    res.json(result.rows);
  } catch (err) {
    console.error("DB error:", err);
    res.status(500).json({ error: "Database query failed" });
  }
});

// ------------------------------------------------------------
// 3️⃣ Autentisering og favoritter
// ------------------------------------------------------------
app.use("/api/auth", authRoutes);
app.use("/api/favoritter", requireCsrf, favorittRoutes);

// ------------------------------------------------------------
// 4️⃣ Start server
// ------------------------------------------------------------
const PORT = process.env.PORT || 3001;
app.listen(PORT, "0.0.0.0", () =>
  console.log(`🚀 API kjører på http://0.0.0.0:${PORT}`)
);

