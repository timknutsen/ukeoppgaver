# Ukeoppgaver

Liten mobil-webapp med ukeoversikt over faste husoppgaver. Trykk på en dag i
ukestripa for å se oppgavene, trykk på en oppgave for å hake den av.

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

Etter dette kan hvert familiemedlem logge inn med navn + PIN. Den som er
`is_admin` får en ekstra "Admin"-fane hvor man ser og kan rette denne ukas
avhukinger for alle. Den gamle localStorage-fremgangen fra før innlogging
ble lagt til, overtas automatisk av den første som logger inn.

**Merk om sikkerhet:** PIN-koden er en enkel gate mot søsken som haker av
hverandres oppgaver — ikke ekte tilgangskontroll. Alle med den offentlige
publishable-nøkkelen kan i prinsippet lese og skrive alles data i `state`
og `earnings` direkte mot Supabase. Helt greit for en husoppgave-app for
familien, men ikke bruk dette mønsteret for noe som faktisk trenger å
være privat.

## Oppgaveplan

| Man | Tir | Ons | Tor | Fre | Lør |
|---|---|---|---|---|---|
| Oppvask | Trappa | Toalett nede | Oppvask | Oppvask | Rydde og vaske rommet |

Planen ligger i `TASKS`-lista øverst i skriptet i `index.html`. `day: 0` er
mandag, `day: 6` er søndag. Legg til, fjern eller flytt oppgaver der.

## Opptjent

Alle seks oppgaver i en uke = 250 kr. Totalen er aldri en løs teller — den
regnes ut fra listen over fullførte uker i `localStorage`
(`ukeoppgaver.opptjent.v1`, `{ ukesats, uker: [...] }`, der `uker` er
mandagsdatoer). En ny uke legges bare til listen når mandagen skifter og alle
seks oppgaver sto avhaket for uka som nettopp gikk; er uka fullført akkurat
nå, vises de 250 kronene som "ikke låst" til mandagen passerer.

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
