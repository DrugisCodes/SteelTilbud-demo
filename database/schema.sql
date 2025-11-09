CREATE DATABASE mattilbud;

CREATE TABLE butikk (
    id SERIAL PRIMARY KEY,
    navn TEXT UNIQUE NOT NULL
);

CREATE TABLE kategori (
    id SERIAL PRIMARY KEY,
    navn TEXT UNIQUE NOT NULL
);

CREATE TABLE produkt (
    id SERIAL PRIMARY KEY,
    navn TEXT UNIQUE NOT NULL,
    kategori_id INT REFERENCES kategori(id)
);

CREATE TABLE produkter (
    id SERIAL PRIMARY KEY,
    produkt_id INT REFERENCES produkt(id),
    butikk_id INT REFERENCES butikk(id),
    pris NUMERIC(10,2),
    mengde NUMERIC(10,2),
    enhet VARCHAR(10),
    pris_per_enhet NUMERIC(10,2),
    pris_per_enhet_enhet VARCHAR(10),
    kilde_fil TEXT,
    dato DATE DEFAULT CURRENT_DATE,
    created_at TIMESTAMPTZ DEFAULT now(),
    UNIQUE (produkt_id, butikk_id)
);

CREATE TABLE pris_historikk (
    id SERIAL PRIMARY KEY,
    produkt_id INT REFERENCES produkt(id),
    butikk_id INT REFERENCES butikk(id),
    pris NUMERIC(10,2),
    mengde NUMERIC(10,2),
    enhet VARCHAR(10),
    pris_per_enhet NUMERIC(10,2),
    pris_per_enhet_enhet VARCHAR(10),
    kilde_fil TEXT,
    gyldig_fra DATE NOT NULL,
    gyldig_til DATE,
    opprettet TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE produkter_rejects (
  id SERIAL PRIMARY KEY,
  reason TEXT,
  kilde_fil TEXT,
  payload JSONB,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE bruker (
    id SERIAL PRIMARY KEY,
    brukernavn VARCHAR(100) UNIQUE NOT NULL,
    passord_hash TEXT NOT NULL,
    opprettet TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE favoritt (
    id SERIAL PRIMARY KEY,
    bruker_id INTEGER REFERENCES bruker(id) ON DELETE CASCADE,
    produkt_id INTEGER REFERENCES produkt(id) ON DELETE CASCADE,
    opprettet TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_produkt_navn ON produkt(navn);
CREATE INDEX idx_butikk_navn ON butikk(navn);
CREATE INDEX idx_pris_hist_dato ON pris_historikk(gyldig_fra, gyldig_til);

CREATE OR REPLACE VIEW v_produktoversikt_full AS
SELECT 
  pr.id,
  b.navn AS butikk,
  k.navn AS kategori,
  p.navn AS produkt,
  pr.pris,
  pr.mengde,
  pr.enhet,
  pr.pris_per_enhet,
  pr.pris_per_enhet_enhet,
  pr.kilde_fil,
  pr.dato
FROM produkter pr
JOIN butikk b ON pr.butikk_id = b.id
JOIN produkt p ON pr.produkt_id = p.id
LEFT JOIN kategori k ON p.kategori_id = k.id;
