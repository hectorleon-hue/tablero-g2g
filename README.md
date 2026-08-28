# Tablero de trabajo — Grow2GetherMx

Compromisos de las reuniones, plan semanal y dashboard de eficiencia.
Héctor y Juan mueven las mismas tarjetas; los avances se guardan solos y cada quien
entra cuando puede, sin necesidad de coincidir en línea.

**Este repositorio contiene sólo la aplicación.** No hay un solo dato de cliente aquí:
las cuentas, los compromisos y el plan semanal viven en Supabase, protegidos por
políticas que sólo admiten a los correos del equipo.

## Puesta en marcha

### 1. Base de datos
1. En https://supabase.com crea un proyecto dentro de la organización Grow2gethermx.
2. **SQL Editor → New query**, pega `supabase.sql` completo y **Run**.
   Crea las tablas, la seguridad por correo y la sincronía en vivo.
3. Nueva query, pega `semilla.sql` y **Run**. Carga las cuentas, los 60 compromisos
   del 17 al 28 de agosto y el plan de la semana.
   *Este archivo sí trae información de clientes: no lo subas a un repositorio público.*
4. **Project Settings → API**, copia el **Project URL** y la **anon public key**.

### 2. Configura
En `index.html`, cerca del inicio del bloque de script:

```js
const SUPABASE_URL  = "PEGA_AQUI_TU_URL";
const SUPABASE_ANON = "PEGA_AQUI_TU_ANON_KEY";
```

La *anon key* es pública por diseño: viaja en el navegador de cualquiera que abra la
página y no da acceso por sí sola. Quién entra lo deciden las políticas de la base:
un correo que no esté en la tabla `equipo` no ve ni un renglón.

### 3. Publica
**Settings → Pages → Source: Deploy from a branch → main / (root)**.
En un par de minutos queda en `https://hectorleon-hue.github.io/tablero-g2g/`.

### 4. Entra
Escribe tu correo y recibirás una liga de acceso. Sin contraseñas.
Mándale la misma liga a Juan.

Para sumar a alguien:

```sql
insert into equipo (correo, nombre) values ('nuevo@grow2gethermx.com', 'Nombre');
```

## Uso

- **Tablero** — Por hacer, En proceso, En espera de tercero, Concluido.
  Arrastra las tarjetas o usa ‹ › desde el celular. Doble clic para editar.
- **Semana** — sesiones agendadas y bloques de trabajo.
- **Eficiencia** — avance, vencidos, carga por responsable y por cuenta,
  y cumplimiento en fecha (compara el cierre real contra la fecha comprometida).

Cada tarjeta conserva la liga a la reunión donde se adquirió el compromiso.

## Actualización semanal

Los compromisos nuevos se insertan directo en la tabla `tareas`:

```sql
insert into tareas (id, t, cuenta, resp, estado, vence, creada, origen_nombre, origen_url, lote)
values ('w36-01', 'Enviar la propuesta', 'lamosa', 'hector', 'pendiente',
        '2026-09-08', '2026-09-04', 'Reunión · 4 sep', 'https://app.read.ai/...', '2026-W36');
```

`resp` es `hector`, `juan`, `ambos` o `tercero`.
`estado` es `pendiente`, `proceso`, `espera` o `concluido`.
Las tarjetas que ya existen conservan su columna y su avance: sólo se agregan las nuevas.

El plan semanal se reemplaza así:

```sql
delete from plan_semana;
insert into plan_semana (dia, fecha, orden, hora, texto, nota, tipo) values
  ('Lunes', '7 de septiembre', 0, '08:00 — 11:00', 'Bloque de trabajo', 'Foco', 'foco');
```

`tipo` es `sesion`, `foco` o `critico`.

## Marca

Navy `#041328`, cian `#33B4D2` (cerebro), rojo `#A5202A` (corazón),
verde `#31A540` (hoja), naranja `#F4A261` (proceso).
Montserrat en títulos, Open Sans en cuerpo.
