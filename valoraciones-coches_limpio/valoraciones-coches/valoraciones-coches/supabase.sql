-- Ejecutar una sola vez en Supabase > SQL Editor.
-- Dos tablas separadas: los envíos privados NUNCA son consultables por visitantes.
create table if not exists public.valoraciones_recibidas (
 id uuid primary key default gen_random_uuid(), created_at timestamptz not null default now(),
 nombre text, email text, estrellas integer not null check(estrellas between 1 and 5),
 profesionalidad text, comunicacion text, fotografias text, anuncio text,
 gestion_interesados text, visitas_negociacion text, mas_valorado text,
 ahorro_tiempo text, mejor_resultado text, volveria text, recomendaria text,
 aspecto_mejorar text, comentario text, autoriza_publicacion boolean not null default false
);
create table if not exists public.valoraciones_publicas (
 id uuid primary key default gen_random_uuid(),
 created_at timestamptz not null default now(),
 nombre text, estrellas integer not null check(estrellas between 1 and 5), comentario text
);
alter table public.valoraciones_recibidas enable row level security;
alter table public.valoraciones_publicas enable row level security;
revoke all on public.valoraciones_recibidas from anon, authenticated;
revoke all on public.valoraciones_publicas from anon, authenticated;
grant usage on schema public to anon;
grant insert on public.valoraciones_recibidas to anon;
grant select on public.valoraciones_publicas to anon;
-- Solo permitir INSERT anónimo; nadie puede leer los envíos privados desde la API pública.
drop policy if exists "Enviar valoracion" on public.valoraciones_recibidas;
create policy "Enviar valoracion" on public.valoraciones_recibidas
 for insert to anon with check (true);
drop policy if exists "Leer opiniones publicadas" on public.valoraciones_publicas;
create policy "Leer opiniones publicadas" on public.valoraciones_publicas
 for select to anon using (true);
-- PUBLICACIÓN MANUAL (desde SQL Editor, tras verificar autorización):
-- Sustituye el UUID por el de la fila de valoraciones_recibidas.
-- insert into public.valoraciones_publicas (nombre, estrellas, comentario, created_at)
-- select nullif(left(nombre, 100), ''), estrellas, comentario, created_at
-- from public.valoraciones_recibidas
-- where id = 'UUID_AQUI' and autoriza_publicacion = true;
-- IMPORTANTE: no incluir nunca email u otras respuestas privadas en la tabla pública.
-- Para producción: añadir protección anti-spam (Captcha + Edge Function),
-- límites de tamaño y una política de privacidad adecuada.
