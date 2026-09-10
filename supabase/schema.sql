-- Oppgaveplan, ukessats og pengebevegelser. Allerede kjørt i prosjektet;
-- ligger her i tilfelle alt må settes opp på nytt et annet sted.
-- (members/state/earnings er satt opp fra før, se README.)

create table if not exists tasks (
  id text primary key,
  day int not null,              -- 0 = mandag ... 6 = søndag
  emoji text not null default '✅',
  label text not null,
  note text not null default '',
  task_order int not null default 0
);

create table if not exists settings (
  id text primary key,
  ukesats int not null default 250
);

-- Pengebevegelser: positivt beløp = bonus/tillegg, negativt = utbetaling.
create table if not exists ledger (
  id bigint generated always as identity primary key,
  member_id text not null references members(id) on delete cascade,
  amount int not null,
  note text not null default '',
  created_at timestamptz not null default now()
);

create index if not exists ledger_member_idx on ledger (member_id, created_at desc);

alter table tasks enable row level security;
alter table settings enable row level security;
alter table ledger enable row level security;

create policy "tasks are readable" on tasks for select using (true);
create policy "tasks are writable" on tasks for insert with check (true);
create policy "tasks are updatable" on tasks for update using (true);
create policy "tasks are deletable" on tasks for delete using (true);

create policy "settings are readable" on settings for select using (true);
create policy "settings are writable" on settings for insert with check (true);
create policy "settings are updatable" on settings for update using (true);

create policy "ledger is readable" on ledger for select using (true);
create policy "ledger is writable" on ledger for insert with check (true);
create policy "ledger is deletable" on ledger for delete using (true);

-- Samme seks oppgaver appen hadde hardkodet fra før.
insert into tasks (id, day, emoji, label, note, task_order) values
  ('oppvask-man', 0, '🍽️', 'Ta oppvasken', 'Tømme og fylle oppvaskmaskin', 0),
  ('trapp',       1, '🧹', 'Vaske trappa', '1 gang i uka', 0),
  ('bad',         2, '🚽', 'Vaske toalett nede', 'Do, servant, gulv', 0),
  ('oppvask-tor', 3, '🍽️', 'Ta oppvasken', 'Tømme og fylle oppvaskmaskin', 0),
  ('oppvask-fre', 4, '🍽️', 'Ta oppvasken', 'Tømme og fylle oppvaskmaskin', 0),
  ('rom',         5, '🛏️', 'Rydde og vaske rommet', 'Rydd først, støvsug etterpå', 0)
on conflict (id) do nothing;

insert into settings (id, ukesats) values ('global', 250)
on conflict (id) do nothing;

-- ---- Ekstraoppgaver ----
-- Menyen admin tilbyr
create table if not exists bonus_tasks (
  id bigint generated always as identity primary key,
  emoji text not null default '⭐',
  label text not null,
  amount int not null,
  active boolean not null default true,
  sort_order int not null default 0
);

-- Innmeldte krav. Label og beløp kopieres inn, slik at historikken overlever
-- at oppgaven senere endres eller slettes.
create table if not exists bonus_claims (
  id bigint generated always as identity primary key,
  bonus_id bigint references bonus_tasks(id) on delete set null,
  member_id text not null references members(id) on delete cascade,
  label text not null,
  emoji text not null default '⭐',
  amount int not null,
  status text not null default 'venter',   -- venter | godkjent | avvist
  created_at timestamptz not null default now(),
  decided_at timestamptz
);

create index if not exists bonus_claims_member_idx on bonus_claims (member_id, created_at desc);
create index if not exists bonus_claims_status_idx on bonus_claims (status);

alter table bonus_tasks enable row level security;
alter table bonus_claims enable row level security;

create policy "bonus_tasks are readable"  on bonus_tasks for select using (true);
create policy "bonus_tasks are writable"  on bonus_tasks for insert with check (true);
create policy "bonus_tasks are updatable" on bonus_tasks for update using (true);
create policy "bonus_tasks are deletable" on bonus_tasks for delete using (true);

create policy "bonus_claims are readable"  on bonus_claims for select using (true);
create policy "bonus_claims are writable"  on bonus_claims for insert with check (true);
create policy "bonus_claims are updatable" on bonus_claims for update using (true);
create policy "bonus_claims are deletable" on bonus_claims for delete using (true);
