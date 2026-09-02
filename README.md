# Ukeoppgaver

Liten mobil-webapp med ukeoversikt over faste husoppgaver. Trykk på en dag i
ukestripa for å se oppgavene, trykk på en oppgave for å hake den av.

- Alt ligger i `index.html`: ingen rammeverk, ingen bygg, ingen server-logikk.
- Avhukinger lagres i nettleseren (`localStorage`) på den enheten som brukes.
- Uka nullstilles automatisk: tilstanden lagres under datoen for mandagen i
  inneværende uke, så alt står på null igjen når en ny uke starter.
- Fungerer offline etter første besøk (`sw.js`), og kan legges til på
  hjem-skjermen som en egen app-ikon (`manifest.webmanifest`).

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
