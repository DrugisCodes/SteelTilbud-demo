import type { Product } from "@/components/ProductCard";

const API_URL = import.meta.env.VITE_API_URL || "http://localhost:3001";

// Shape coming from /api/produkter
type DbProductRow = {
  id: string;
  produkt: string; // name
  butikk: string; // store
  kategori: string | null;
  pris: number | string; // kan være tekst som "3 for 2"
  rabatt: number | string | null; // prosent eller tekst
  mengde?: string | null;
  enhet?: string | null;
  pris_per_enhet?: number | null;
  pris_per_enhet_enhet?: string | null;
};

const addDays = (days: number) => {
  const d = new Date();
  d.setDate(d.getDate() + days);
  return d.toISOString();
};

export async function fetchProducts(): Promise<Product[]> {
  const res = await fetch(`${API_URL}/api/produkter`);
  if (!res.ok) {
    const text = await res.text().catch(() => "");
    throw new Error(`API ${res.status}: ${text}`);
  }

  const rows: DbProductRow[] = await res.json();

  const toCanonicalCategory = (raw: string | null | undefined, name: string): string => {
    const s = (raw || "").toString().trim();
    const lower = s.toLowerCase();
    const nameLower = name.toLowerCase();

    // Map vanlige varianter til "Frukt og grønt"
    const fruitVegKeys = [
      "frukt", "grønt", "gront", "frukt/grønt", "frukt/gront", "frukt og grønt", "frukt og gront",
      "frukt & grønt", "frukt & gront", "grønnsaker", "gronnsaker", "vegetables", "produce"
    ];
    const isFruitVegCategory = fruitVegKeys.some(k => lower.includes(k));

    // Heuristikk basert på produktnavn når kategori mangler/er feil
    const fruitVegKeywords = [
      // grønnsaker
      "brokkoli","blomkål","gulrot","gulrøtter","potet","poteter","tomat","tomater","agurk","paprika","løk","gul løk","rødløk","salat","spinat","kål","hodekål","kinakål","avokado","agurker",
      // frukt/bær
      "eple","epler","banan","bananer","pære","pærer","appelsin","appelsiner","mandarin","mandariner","druer","jordbær","blåbær","bringebær","melon","honningmelon","vannmelon","kiwi"
    ];
    const looksLikeFruitVeg = fruitVegKeywords.some(k => nameLower.includes(k));

    if (isFruitVegCategory || looksLikeFruitVeg) return "Frukt og grønt";
    if (!s) return "Annet";
    return s; // ellers behold original
  };

  return rows.map((r) => {
    // --- Prisbehandling ---
    const rawPris = r.pris as unknown;
    let price: number | string = 0;

    if (typeof rawPris === "number" && Number.isFinite(rawPris)) {
      price = round2(rawPris);
    } else if (typeof rawPris === "string") {
      const trimmed = rawPris.trim();
      const numericOnly = /^-?\d+(?:[.,]\d+)?$/.test(trimmed);
      if (numericOnly) {
        const parsed = Number(trimmed.replace(",", "."));
        price = Number.isFinite(parsed) ? round2(parsed) : trimmed;
      } else {
        price = trimmed; // behold tekst som "3 for 2"
      }
    }

    // --- Rabattbehandling ---
    const rawRabatt = r.rabatt as unknown;
    let discount: number | string = 0;
    if (typeof rawRabatt === "number" && Number.isFinite(rawRabatt)) {
      discount = Math.round(rawRabatt);
    } else if (typeof rawRabatt === "string" && rawRabatt.trim()) {
      discount = rawRabatt.trim();
    }

    // 💡 Hvis pris inneholder tekst som "3 for 2", bruk den som rabatttekst også
    if (typeof price === "string" && price.toLowerCase().includes("for")) {
      discount = price;
    }

    // --- Beregn originalpris når mulig ---
    let originalPrice: number | string = "";
    if (
      typeof price === "number" &&
      typeof discount === "number" &&
      discount > 0 &&
      discount < 100
    ) {
      originalPrice = round2(price / (1 - discount / 100));
    } else if (typeof price === "number") {
      originalPrice = price;
    }

    // --- Returner produktobjekt ---
    const product: Product = {
      id: String(r.id),
      name: r.produkt,
      category: toCanonicalCategory(r.kategori, r.produkt),
      store: r.butikk,
      price,
      originalPrice,
      discount,
      image: "",
      validUntil: addDays(7),

      mengde: r.mengde ?? null,
      enhet: r.enhet ?? null,
      pris_per_enhet: r.pris_per_enhet ?? null,
      pris_per_enhet_enhet: r.pris_per_enhet_enhet ?? null,
    };

    return product;
  });
}

function round2(n: number) {
  return Math.round(n * 100) / 100;
}
