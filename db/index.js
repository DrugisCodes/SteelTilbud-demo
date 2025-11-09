/*
import pg from "pg";
import dotenv from "dotenv";

dotenv.config();

const { Pool } = pg;

const pool = new Pool({
  user: process.env.DB_USER || "postgres",
  host: process.env.DB_HOST || "localhost",
  database: process.env.DB_NAME || "mattilbud",
  password: process.env.DB_PASS || "postgres",
  port: process.env.DB_PORT || 5432,
});

export default {
  query: (text, params) => pool.query(text, params),
};
*/

// ✅ Ny Render-versjon
import pg from "pg";
import dotenv from "dotenv";
dotenv.config();

const { Pool } = pg;

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: { rejectUnauthorized: false },
});

export default {
  query: (text, params) => pool.query(text, params),
};

