import re

def detect_mismatch(item):
    """
    Enkel heuristisk validering:
    Returnerer feilkode (str) hvis noe virker off, ellers None.
    """
    prod = (item.get('produkt') or '').strip().lower()
    pris = (item.get('pris') or '').strip().lower()
    mengde = (item.get('mengde') or '').strip().lower()

    # 1️⃣ Manglende eller veldig kort produktnavn
    if not prod or len(prod) < 3:
        return 'missing_or_short_product'

    # 2️⃣ Nonsens-pris (tekst uten tall eller prosent)
    if not re.search(r"\d", pris) and '%' not in pris:
        if pris not in ['pakkepris', 'medlemspris', 'gratis']:
            return 'nonsense_price_text'

    # 3️⃣ Ugyldig mengdeformat
    if mengde:
        if (
            re.search(r"\d", mengde) is None
            and not any(x in mengde for x in ['stk', 'pk', 'l', 'g', 'hg', 'dl', 'ml'])
        ):
            return 'weird_quantity'

    # 4️⃣ Feilkobling mellom type produkt og kampanjepris
    if any(k in prod for k in ["potet", "eple", "pære", "banan"]) and "for" in pris:
        return "discount_mismatch"

    return None
