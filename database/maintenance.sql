CREATE OR REPLACE FUNCTION move_old_price_to_history()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.pris IS DISTINCT FROM OLD.pris THEN
        INSERT INTO pris_historikk (
            produkt_id, butikk_id, pris, mengde, enhet,
            pris_per_enhet, pris_per_enhet_enhet,
            kilde_fil, gyldig_fra, gyldig_til
        )
        VALUES (
            OLD.produkt_id, OLD.butikk_id, OLD.pris, OLD.mengde, OLD.enhet,
            OLD.pris_per_enhet, OLD.pris_per_enhet_enhet,
            OLD.kilde_fil, OLD.dato, CURRENT_DATE
        );
    END IF;
    NEW.dato := CURRENT_DATE;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_move_old_price
BEFORE UPDATE ON produkter
FOR EACH ROW
EXECUTE FUNCTION move_old_price_to_history();

ALTER TABLE pris_historikk
ADD COLUMN IF NOT EXISTS registrert_tid TIMESTAMPTZ DEFAULT now(),
ADD COLUMN IF NOT EXISTS uke_nr INT;

ALTER TABLE produkter ADD COLUMN IF NOT EXISTS rabatt TEXT;
ALTER TABLE pris_historikk ADD COLUMN IF NOT EXISTS rabatt TEXT;

ALTER ROLE postgres WITH PASSWORD 'flniqvdoyoxdh';
