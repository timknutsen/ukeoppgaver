# Ukeoppgaver

Liten mobil-webapp med ukeoversikt over faste husoppgaver. Trykk på en dag i
ukestripa for å se oppgavene, trykk på en oppgave for å hake den av.

## Streak-stripa

Ukestripa er bygget etter mønsteret fra Duolingo: hver dag som er helt ferdig
blir en flamme-gul markør, og **nabodager smelter sammen til én sammenhengende
stolpe** i stedet for å stå som løse prikker. Flammen øverst teller uker på
rad, og søndag er belønningsplassen med en stjerne.

Stjerna sitter alltid på ukas siste dag, enten den dagen er fri eller har en
oppgave — den er belønningsplassen, ikke en dag i seg selv.

Når alle ukas oppgaver er avhaket blir hele uka én gyllen stolpe med
skimmer-animasjon, stjerna fylles, flammen får glorie (Duolingos markør for
perfekt streak), og det spretter konfetti. Feiringsarket viser flammen med
strålekrans, beløpet og hvor mange uker på rad. Alt av animasjon er slått av
under `prefers-reduced-motion`.

## Lyd

Avhuking gir et kort stigende «pling», å fjerne avhukingen gir en dempet
nedadgående tone, og perfekt uke gir en liten fanfare. Tonene lages i Web
Audio underveis — ingen lydfiler å laste ned, så det virker offline også.
Høyttaler-knappen nede til høyre skrur lyden av og på, og valget huskes i
`localStorage` (`ukeoppgaver.lyd.v1`).

- Alt ligger i `index.html`: ingen rammeverk, ingen bygg-steg.
- Hvert familiemedlem logger inn med navn + 4-sifret PIN, og avhukinger
  lagres både i nettleseren (`localStorage`, for offline-bruk) og i Supabase
  (Postgres) (så fremgangen følger med på tvers av enheter).
- Uka nullstilles automatisk: tilstanden lagres under datoen for mandagen i
  inneværende uke, så alt står på null igjen når en ny uke starter.
- Fungerer offline etter første besøk (`sw.js`), og kan legges til på
  hjem-skjermen som en egen app-ikon (`manifest.webmanifest`).

## Innlogging og admin (Supabase-oppsett)

Appen bruker Supabase (Postgres + REST-API) for pålogging og lagring i
skyen — ingen egen auth, bare tabeller med åpne (men avgrensede)
sikkerhetsregler. Prosjekt-URL og publishable-nøkkel er allerede limt inn i
`index.html`. Tabellene (`members`, `state`, `earnings`) og
sikkerhetsreglene er satt opp i det tilkoblede Supabase-prosjektet.

Legg inn familiemedlemmene i tabellen `members` (Supabase Studio → Table
editor → members → Insert row). Én rad per person:
- `id` (text, primærnøkkel) — kort id, f.eks. `tim`, `emma`
- `name` (text) — vises på innloggingsskjermen
- `pin` (text) — 4 sifre, f.eks. `"1234"`
- `is_admin` (bool) — `true` for deg, `false` for barna
- `member_order` (int) — rekkefølge på innloggingsskjermen

Tabellene er allerede opprettet i prosjektet: `members`, `state`, `earnings`,
`tasks`, `settings` og `ledger`. `supabase/schema.sql` er kopien av
oppsettet, hvis alt må settes opp på nytt et annet sted.

Etter dette kan hvert familiemedlem logge inn med navn + PIN. Den gamle
localStorage-fremgangen fra før innlogging ble lagt til, overtas automatisk
av den første som logger inn.

## Admin

Den som er `is_admin` har ingen egne oppgaver: da vises bare Admin-fanen,
ikke Uke og Opptjent. Admin-fanen har, per barn:

- **Pengebeholdning** — til gode, opptjent totalt og utbetalt totalt, pluss
  antall perfekte uker og lengste rekke. Er det flere barn, vises også en
  sum for hele huset øverst.
- **Denne uka** — hvor mange oppgaver som er gjort, med avhukingsbokser som
  kan rettes direkte, og knappene "Hak av hele uka" / "Nullstill uka".
- **Utbetalinger og bonus** — "Betal ut" fører hele saldoen som utbetalt,
  "Delbetaling…" et valgfritt beløp, og "+ Bonus…" legger til kroner utenom
  ukessatsen (med en begrunnelse). Alt havner i `ledger`-tabellen og vises
  i "Pengehistorikk", der en feilføring kan slettes.
- **Oppgaveplan og ukessats** — se under.

Regnestykket: `til gode = perfekte uker × ukessats + bonuser − utbetalt`.

## Ekstraoppgaver

Utenom den faste ukeplanen finnes en meny med ekstraoppdrag som gir penger
i tillegg — «Vaske bilen – 100 kr», «Måke snø – 50 kr». Admin styrer menyen
i «Ekstraoppgaver»-boksen i Admin-fanen.

Barna ser menyen i «Ekstra»-fanen og trykker når de har gjort et oppdrag.
Da havner det til godkjenning: admin får et varselmerke på Admin-fanen og et
kort øverst med «Godkjenn» / «Avvis». Først ved godkjenning føres beløpet inn
i `ledger`, så det teller som til gode og dukker opp i barnets «Opptjent».

Hvert oppdrag kan meldes inn maks én gang per dag — knappen sperres mens et
krav venter eller er godkjent samme dag. Blir kravet avvist, telles det
ikke, og oppdraget kan meldes inn på nytt med en gang.

Tabellene er `bonus_tasks` (menyen) og `bonus_claims` (innmeldte krav, med
status `venter`/`godkjent`/`avvist`). Kravet lagrer sin egen kopi av navn og
beløp, slik at historikken står seg selv om oppdraget senere endres eller
slettes. Kurven på «Opptjent» viser bare ukelønna — er det tjent penger på
ekstraoppgaver i tillegg, står det som en egen linje under kurven.

**Merk om sikkerhet:** PIN-koden er en enkel gate mot søsken som haker av
hverandres oppgaver — ikke ekte tilgangskontroll. Alle med den offentlige
publishable-nøkkelen kan i prinsippet lese og skrive alles data i `state`
og `earnings` direkte mot Supabase. Helt greit for en husoppgave-app for
familien, men ikke bruk dette mønsteret for noe som faktisk trenger å
være privat.

## Oppgaveplan

Oppgavene og ukessatsen ligger i Supabase (`tasks`- og `settings`-tabellene),
ikke hardkodet i JS lenger. Admin-fanen har en "Oppgaveplan"-boks der man
kan endre dag/emoji/tittel/notat på hver oppgave, legge til eller slette
oppgaver, og en "Ukessats"-boks for å endre kronebeløpet. Enhver endring
lagrer til Supabase og laster appen på nytt.

Utgangspunktet, seedet av `supabase/tasks_and_settings.sql`:

| Man | Tir | Ons | Tor | Fre | Lør |
|---|---|---|---|---|---|
| Oppvask | Trappa | Toalett nede | Oppvask | Oppvask | Rydde og vaske rommet |

## Opptjent

Alle oppgavene i en uke = ukessatsen (250 kr som standard). Totalen er aldri
en løs teller — den regnes ut fra listen over fullførte uker i
`localStorage` (`ukeoppgaver.opptjent.v1.<medlem>`, `{ ukesats, uker: [...] }`,
der `uker` er mandagsdatoer), synket med Supabase. En ny uke legges bare til
listen når mandagen skifter og alle oppgaver sto avhaket for uka som nettopp
gikk; er uka fullført akkurat nå, vises kronene som "ikke låst" til mandagen
passerer.

"Opptjent"-fanen viser totalen, antall perfekte uker, lengste rekke og en
kumulativ kurve med én posisjon per kalenderuke — bomma uker blir flate
partier. Kurven har sikte-strek med verdi ved hover, piltast-navigasjon ved
tastaturfokus, og en `Alle uker`-tabell så ingen verdi bare finnes i et
verktøytips. Den gamle nøkkelen `ukeoppgaver.mal.v1` (Garmin-målet) migreres
automatisk første gang appen åpnes.

## Kjøre lokalt

```
python3 -m http.server 4321
```

Åpne så http://localhost:4321

## Etter endringer

Bump `CACHE`-navnet i `sw.js` (f.eks. `ukeoppgaver-v2`), ellers kan telefoner
med appen på hjem-skjermen bli liggende på gammel versjon en stund.
