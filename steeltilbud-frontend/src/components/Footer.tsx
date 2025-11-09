const Footer = () => {
  return (
    <footer className="mt-16 border-t border-border bg-card/50">
      <div className="container mx-auto px-4 py-12">
        <div className="grid gap-8 md:grid-cols-2 lg:grid-cols-3">
          {/* Om oss */}
          <div>
            <h3 className="mb-4 text-lg font-bold">Ansvarsfraskrivelse</h3>
            <p className="text-sm text-muted-foreground leading-relaxed">
             
 SteelTilbud samler og viser tilbud fra offentlige kundeaviser og butikkjeder.
  Vi gjør vårt beste for å sikre at informasjonen er korrekt og oppdatert,
  men kan ikke garantere at prisene eller tilgjengeligheten alltid stemmer med de faktiske forholdene i butikk.
  Alle varemerker, logoer og produktbilder tilhører sine respektive eiere.
  Sjekk alltid pris og tilgjengelighet i din lokale butikk før kjøp.
  <br /><br />
  <b>Merk:</b> SteelTilbud viser primært kundeaviser fra <b>Vestland/Bergen-området</b>.
  Prisene og produktene kan variere fra butikk til butikk. Vi anbefaler å sjekke din lokale kundeavis for oppdaterte tilbud.
</p>
          </div>

          {/* Om utvikleren */}
<div>
  <h3 className="mb-4 text-lg font-bold">Om prosjektet</h3>
  <p className="text-sm text-muted-foreground leading-relaxed">
    SteelTilbud er et hobbyprosjekt laget for å samle mattilbud fra norske butikker 
    på ett sted. Prosjektet er ikke tilknyttet noen dagligvarekjede, 
    og dataene hentes automatisk fra offentlige kundeaviser.
  </p>

  <p className="text-sm text-muted-foreground mt-3">
    Har du spørsmål eller oppdager feil?  
    Kontakt meg på <a href="mailto:steeltilbud@gmail.com" className="text-primary hover:underline">
      sigurd.steelisland@gmail.com
    </a>
  </p>
</div>


          {/* Info */}
          <div>
            <h3 className="mb-4 text-lg font-bold">Informasjon</h3>
            <p className="text-sm text-muted-foreground leading-relaxed">
              Tilbudene oppdateres ukentlig. Priser og tilgjengelighet kan variere
              mellom butikker og regioner. Sjekk alltid med din lokale butikk.
              <br />
              <br />Butikker vi dekker:
              <li>KIWI</li>
              <li>Rema 1000</li>
              <li>Coop Extra</li>
              <li>Bunnpris</li>
              <li>Spar</li>
              <li>Meny</li>
            </p>
          </div>
        </div>

        <div className="mt-8 border-t border-border pt-8 text-center">
          <p className="text-sm text-muted-foreground">
            © 2025 SteelTilbud. Et raskt søk etter billgste tilbud.
          </p>
        </div>
      </div>
    </footer>
  );
};

export default Footer;
