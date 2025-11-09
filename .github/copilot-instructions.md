# SteelTilbud — AI coding agent instructions

This repository powers a price-comparison site for Norwegian grocery offers.
Your job as an AI agent is to keep 3 parts in sync: Python scrapers, a Node/Express API, and a Vite/React frontend.

## Architecture overview (what talks to what)
- Data ingestion (Python):
  - `butikk_henting/*.py` and `automatisk/*.py` fetch or parse weekly “kundeavis” offers, capture images/PDFs, and produce data.
  - Artifacts live in `resultater/` (JSON per chain/date), `resultater/rejects/` (invalid rows), and `kundeaviser/Egen_avis/` (PDF screenshots of circulars).
- Database (PostgreSQL):
  - Connection via `db/index.js` using `process.env.DATABASE_URL` (SSL on by default) or the commented local Pool config.
  - Schema and helpers in `database/*.sql`. Backend queries rely on tables `produkt`, `produkter`, `butikk`, (optionally view) `v_produktoversikt_full`.
- Backend API (Node/Express, ESM):
  - Entry: `server.js`. Routes: `/api/produkter`, `/api/sok`, `/api/auth`, `/api/favoritter`.
  - `middleware/csrf.js` is a placeholder (no real CSRF validation yet). `routes/favoritter.js` stores favorites in-memory (restart loses data).
- Frontend app (Vite + React + TS):
  - Located in `steeltilbud-frontend/`. Reads API base from `VITE_API_URL` (defaults to `http://localhost:3001`).
  - Data mapping in `steeltilbud-frontend/src/lib/api.ts` converts DB rows → UI `Product` shape used by `src/pages/Index.tsx`.

## Dev workflows (commands that actually work)
- API (server):
  - Prereq: Node 18+ (ESM) and a reachable Postgres (set `DATABASE_URL`).
  - Start: `node server.js` (from repo root). API binds on `PORT` (default 3001) to `0.0.0.0`.
- Frontend (app):
  - From `steeltilbud-frontend/`: `npm i` then `npm run dev`. Set `VITE_API_URL` to your API (e.g. http://localhost:3001).
- Scrapers / utilities (Python):
  - Require Python 3.10+.
  - Example: `butikk_henting/meny.py` opens MENY’s circular, screenshots all pages, merges to a single PDF at `kundeaviser/Egen_avis/`.
  - Playwright and Pillow are used for browser control and PDF merge. Install: `pip install playwright pillow` then `python -m playwright install`.
  - Import to DB is handled by scripts in `automatisk/` (e.g., `importer_til_db.py`) and SQL in `database/`.

## Conventions and patterns unique to this repo
- Node uses ESM (`"type": "module"`); use `import`/`export`, not `require`.
- DB access centralised in `db/index.js` via `db.query(text, params)`; prefer parametrized SQL.
- API response shape consumed by frontend is normalized in `src/lib/api.ts` (e.g., `discount` normalized, `originalPrice` derived). Keep this mapping stable when changing SQL columns.
- Frontend state and UX:
  - Querying via `@tanstack/react-query` in `src/pages/Index.tsx`; sorting toggles and filters are client-side.
  - Shopping list is stored in `localStorage` by product `id` as strings.
- Data files naming convention: `resultater/<BUTIKK_YYYYMMDD>.json` and `resultater/rejects/<BUTIKK_YYYYMMDD>_rejects.json`.
- Security is minimal by design (demo): `csrf.js` is a no-op, `auth` is hard-coded. Don’t rely on these in production.

## Adding or changing features
- New API endpoints: add a route under `routes/`, import in `server.js`, and query Postgres via `db.query`. Mirror any shape changes in `steeltilbud-frontend/src/lib/api.ts`.
- SQL changes: update `database/schema.sql` (and any views like `v_produktoversikt_full`) to keep `/api/sok` working.
- Frontend data: extend `Product` in `components/ProductCard.tsx` and update the mapping in `src/lib/api.ts`.
- Scrapers: keep outputs consistent with columns the API expects (`produkt`, `butikk`, `kategori`, `pris`, `rabatt`, …). Store raw outputs in `resultater/` and let importer scripts write to DB.

## Examples (files to look at)
- Query shape: `server.js` → the SQL under `/api/produkter` shows the expected columns and joins.
- Frontend mapping: `steeltilbud-frontend/src/lib/api.ts` (maps DB → UI `Product`).
- End-to-end circular capture: `butikk_henting/meny.py` (Playwright navigation + PDF merge).

## Gotchas
- If `/api/sok` errors, ensure the view `v_produktoversikt_full` exists or update the query to a concrete table.
- The backend `package.json` contains Vite tooling but is not used for the server; run the API with `node server.js`.
- Favorites are volatile (in-memory) until replaced with DB-backed storage.
