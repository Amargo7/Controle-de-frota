-- ============================================================
-- Controle de Frota — schema do banco de dados (Supabase / PostgreSQL)
-- Como usar: no painel do Supabase, vá em "SQL Editor" > "New query",
-- cole todo este arquivo e clique em "Run".
-- ============================================================

create table if not exists veiculos (
  id uuid primary key default gen_random_uuid(),
  placa text not null,
  modelo text,
  tipo text,                    -- 'carro' | 'moto' | 'carrocinha' | 'outro'
  coordenador text,
  contrato text,                -- ex: "33195 - Shopping da Bahia"
  crlv_vencimento date,
  ipva_vencimento date,
  criado_em timestamptz not null default now(),
  atualizado_em timestamptz not null default now()
);

-- Mantém "atualizado_em" sempre correto a cada alteração
create or replace function set_atualizado_em()
returns trigger as $$
begin
  new.atualizado_em = now();
  return new;
end;
$$ language plpgsql;

drop trigger if exists trg_veiculos_atualizado_em on veiculos;
create trigger trg_veiculos_atualizado_em
before update on veiculos
for each row execute function set_atualizado_em();

-- Row Level Security: como este projeto é de uso pessoal (sem login),
-- liberamos leitura/escrita para quem tiver a chave "anon".
-- Essa chave NÃO fica no código público — o app pede ela em tempo de
-- execução e guarda apenas no navegador de quem configurar (veja README).
alter table veiculos enable row level security;

drop policy if exists "acesso total via anon key" on veiculos;
create policy "acesso total via anon key"
on veiculos
for all
using (true)
with check (true);
