-- ============================================================
-- Tablero de trabajo · Grow2GetherMx — estructura y seguridad
-- Ejecutar una sola vez: Supabase → SQL Editor → New query → Run
-- Después, ejecutar semilla.sql para cargar los datos.
-- ============================================================

-- 1. Quiénes pueden entrar
create table if not exists equipo (
  correo text primary key,
  nombre text
);
insert into equipo (correo, nombre) values
  ('hector.leon@grow2gethermx.com', 'Héctor León'),
  ('juan.bernal@grow2gethermx.com', 'Juan Bernal')
on conflict (correo) do nothing;

-- 2. Cuentas y clientes
create table if not exists cuentas (
  clave  text primary key,
  nombre text not null,
  orden  integer default 0
);

-- 3. Tarjetas del tablero
create table if not exists tareas (
  id            text primary key,
  t             text not null,
  cuenta        text references cuentas(clave),
  resp          text,
  estado        text default 'pendiente',
  vence         date,
  creada        date,
  cerrada       date,
  origen_nombre text,
  origen_url    text,
  por           text,
  lote          text,
  actualizado   timestamptz default now()
);

-- 4. Plan de la semana
create table if not exists plan_semana (
  id     bigserial primary key,
  dia    text,
  fecha  text,
  orden  integer,
  hora   text,
  texto  text,
  nota   text,
  tipo   text default 'sesion'   -- sesion | foco | critico
);

-- 5. Control de la siembra semanal
create table if not exists meta_lotes (
  lote   text primary key,
  n      integer,
  cuando timestamptz default now()
);

-- 6. Seguridad: sólo los correos de la tabla equipo leen y escriben
alter table equipo      enable row level security;
alter table cuentas     enable row level security;
alter table tareas      enable row level security;
alter table plan_semana enable row level security;
alter table meta_lotes  enable row level security;

create or replace function es_del_equipo() returns boolean as $$
  select exists (
    select 1 from equipo
    where correo = lower(coalesce(auth.jwt() ->> 'email', ''))
  );
$$ language sql security definer stable;

do $$
declare tabla text;
begin
  foreach tabla in array array['equipo','cuentas','tareas','plan_semana','meta_lotes'] loop
    execute format('drop policy if exists %I_lee on %I', tabla, tabla);
    execute format('drop policy if exists %I_escribe on %I', tabla, tabla);
    execute format('create policy %I_lee on %I for select using (es_del_equipo())', tabla, tabla);
    execute format('create policy %I_escribe on %I for all using (es_del_equipo()) with check (es_del_equipo())', tabla, tabla);
  end loop;
end $$;

-- 7. Sincronía en vivo entre Héctor y Juan
alter publication supabase_realtime add table tareas;

-- 8. Marca de tiempo automática
create or replace function toca_actualizado() returns trigger as $$
begin new.actualizado = now(); return new; end;
$$ language plpgsql;
drop trigger if exists tareas_actualizado on tareas;
create trigger tareas_actualizado before insert or update on tareas
for each row execute function toca_actualizado();
