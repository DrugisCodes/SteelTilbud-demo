# SteelTilbud (Demo)

**SteelTilbud** er en fullstack-løsning som samler, strukturerer og presenterer dagligvaretilbud fra norske butikker.  
Denne demoen viser den tekniske oppbygningen og arkitekturen bak prosjektet – uten private nøkler, OCR-kilder eller databaseinnhold.

---

##  Formål
Prosjektet ble laget for å:
- automatisere innhenting av ukentlige kundeaviser (PDF),
- bruke OCR og AI-analyse til å trekke ut pris, mengde og produktinformasjon,
- lagre strukturert data i en PostgreSQL-database,
- og presentere resultatene på en rask og moderne webplattform.

---

## Teknologistack

**Frontend**
- React + Vite + TypeScript  
- Tailwind CSS  
**Backend**
- Node.js + Express  
- PostgreSQL (via `pg`)  

**OCR-/datainnsamlingspipeline (utelatt i demo)**
- Python (Playwright, OpenCV, Tesseract, GPT-analyse)
- Automatisk import til database


##  Arkitektur

SteelTilbud består av tre hoveddeler:

SteelTilbud-demo/
├── steeltilbud-frontend/ # React + Vite frontend
│ ├── src/ # Komponenter, hooks og sider
│ ├── public/ # Ikoner, logoer og statiske ressurser
│ └── vite.config.ts # Vite-konfigurasjon
│
├── routes/ # Express API-ruter (autentisering, favoritter, produkter)
├── middleware/ # Felles mellomvare (CSRF, sikkerhet, logging)
├── db/ # Databasekobling og spørringer (PostgreSQL)
├── server.js # Hovedserver som kobler sammen alle rutene
│
├── automatisk/ # (Utelatt i demo) Python/OCR-pipeline for innhenting av kundeaviser
├── kundeaviser/ # (Utelatt i demo) Lagring av nedlastede avisbilder
├── resultater/ # (Utelatt i demo) JSON-resultater fra OCR-lesing
│
├── .gitignore # Ignorerer miljøfiler, cache og byggeartefakter
├── package.json # Avhengigheter og scripts for backend
└── README.md # Prosjektbeskrivelse og dokumentasjon

## Skjermbilder (fra fullversjonen)
![Forside](./docs/screenshots/forside.png)
![kategori](./docs/screenshots/kategori.png)
![handleliste](./docs/screenshots/handleliste.png)

##  Utviklet av
**Sigurd Ståløy**  
Dataingeniørstudent – HVL  
[GitHub.com/DrugisCodes](https://github.com/DrugisCodes)
