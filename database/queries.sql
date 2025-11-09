SELECT * FROM butikk;
--passord = pass123
ALTER TABLE pris_historikk
ADD COLUMN IF NOT EXISTS pris_per_kg NUMERIC,
ADD COLUMN IF NOT EXISTS total_vekt_g NUMERIC;

ALTER TABLE produkter
ADD COLUMN IF NOT EXISTS pris_per_kg NUMERIC,
ADD COLUMN IF NOT EXISTS total_vekt_g NUMERIC;


UPDATE produkter
SET butikk_id = 6
WHERE butikk_id = 8;

UPDATE pris_historikk
SET butikk_id = 6
WHERE butikk_id = 8;


DELETE FROM butikk
WHERE id = 8;

SELECT COUNT(*) FROM produkter;
SELECT COUNT(*) FROM pris_historikk;
SELECT MAX(dato) FROM produkter;
SELECT * FROM v_produktoversikt_full LIMIT 10;

SELECT DISTINCT navn FROM kategori ORDER BY navn;



TRUNCATE TABLE 
    produkter_rejects,
    produkter_historikk,
    pris_historikk,
    produkter,
    produkt,
    kategori,
    butikk,
    favoritt,
    bruker
RESTART IDENTITY CASCADE;

SELECT produkt_id, pris, rabatt, mengde, enhet, kilde_fil
FROM produkter
WHERE rabatt IS NOT NULL AND rabatt <> ''
LIMIT 20;

CREATE OR REPLACE FUNCTION logg_pris_endring()
RETURNS TRIGGER AS $$
BEGIN
    -- bare lagre hvis verdiene faktisk endres
    IF (
        NEW.pris IS DISTINCT FROM OLD.pris OR
        NEW.mengde IS DISTINCT FROM OLD.mengde OR
        NEW.enhet IS DISTINCT FROM OLD.enhet OR
        NEW.pris_per_enhet IS DISTINCT FROM OLD.pris_per_enhet OR
        NEW.rabatt IS DISTINCT FROM OLD.rabatt
    ) THEN
        INSERT INTO pris_historikk (
            produkt_id,
            butikk_id,
            pris,
            mengde,
            enhet,
            pris_per_enhet,
            pris_per_enhet_enhet,
            kilde_fil,
            gyldig_fra,
            gyldig_til
        ) VALUES (
            OLD.produkt_id,
            OLD.butikk_id,
            OLD.pris,
            OLD.mengde,
            OLD.enhet,
            OLD.pris_per_enhet,
            OLD.pris_per_enhet_enhet,
            OLD.kilde_fil,
            OLD.dato,
            CURRENT_DATE
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER produkter_logg_til_historikk
BEFORE UPDATE ON produkter
FOR EACH ROW
EXECUTE FUNCTION logg_pris_endring();

ALTER TABLE produkter
ADD CONSTRAINT uniq_produkt_butikk UNIQUE (produkt_id, butikk_id);

UPDATE kategori SET navn = 'Frossenvarer' WHERE navn ILIKE 'Frossenmat';
UPDATE kategori SET navn = 'Tørrvarer' WHERE navn ILIKE 'Tørrvareprodukter';

DELETE FROM produkter WHERE dato = CURRENT_DATE;

TRUNCATE TABLE produkter RESTART IDENTITY CASCADE;

DROP TRIGGER IF EXISTS trig_logg_pris_endring ON produkter;

DROP TRIGGER IF EXISTS produkter_logg_til_historikk ON produkter;

DROP FUNCTION IF EXISTS logg_pris_endring();


-- Flytt gamle produkter til historikk
INSERT INTO pris_historikk (
    produkt_id,
    butikk_id,
    pris,
    mengde,
    enhet,
    pris_per_enhet,
    pris_per_enhet_enhet,
    kilde_fil,
    gyldig_fra,
    gyldig_til
)
SELECT
    produkt_id,
    butikk_id,
    pris,
    mengde,
    enhet,
    pris_per_enhet,
    pris_per_enhet_enhet,
    kilde_fil,
    dato,
    CURRENT_DATE
FROM produkter
WHERE dato < CURRENT_DATE
ON CONFLICT (produkt_id, butikk_id, gyldig_fra, pris) DO NOTHING;

-- Deretter slett de gamle fra produkter-tabellen
DELETE FROM produkter
WHERE dato < CURRENT_DATE;


UPDATE produkt
SET kategori_id = (
    SELECT id FROM kategori WHERE navn ILIKE 'Drikke'
)
WHERE navn ILIKE '%Farris%';
