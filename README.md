# Controle de Frota

Sistema simples para controlar o vencimento de CRLV e IPVA da frota de veículos da empresa, com aviso antecipado (10-15 dias) antes do vencimento para evitar multa por documentação vencida.

## Como funciona

- **Frontend:** um único arquivo `index.html` (HTML + CSS + JavaScript puro, sem build).
- **Banco de dados:** [Supabase](https://supabase.com) (PostgreSQL real, plano gratuito).
- **Hospedagem:** GitHub Pages (gratuito).
- A URL e a chave do seu banco de dados **não ficam gravadas no código**. O app pede essas informações na primeira vez que é aberto no navegador e guarda só ali (localStorage). Isso permite postar o código publicamente no GitHub sem expor seus dados.

## Passo 1 — Criar o banco de dados no Supabase (grátis)

1. Crie uma conta em [supabase.com](https://supabase.com) e clique em **New project**.
2. Escolha um nome e uma senha para o banco (guarde a senha, mas ela não será usada no app).
3. Espere o projeto ser criado (leva 1-2 minutos).
4. No menu lateral, vá em **SQL Editor** → **New query**.
5. Abra o arquivo `schema.sql` (junto com este README), copie todo o conteúdo, cole no editor e clique em **Run**.
6. Isso cria a tabela `veiculos` já com as colunas certas.

## Passo 2 — Pegar a URL e a chave do projeto

1. No painel do Supabase, vá em **Project Settings** (ícone de engrenagem) → **API**.
2. Copie o valor de **Project URL** (algo como `https://xxxxx.supabase.co`).
3. Copie o valor de **anon public** em "Project API keys".
4. Guarde os dois — você vai colar na primeira tela do app.

## Passo 3 — Publicar o app gratuitamente (GitHub Pages)

1. Crie um repositório novo no GitHub (pode ser público — o código não tem nenhuma senha).
2. Envie o arquivo `index.html` para a raiz do repositório.
3. Vá em **Settings** → **Pages** do repositório.
4. Em "Source", selecione a branch (geralmente `main`) e a pasta `/root`, e salve.
5. Em alguns minutos o GitHub mostra o link do tipo `https://seu-usuario.github.io/nome-do-repo/` — esse é o endereço do seu sistema, acessível de qualquer dispositivo.

## Passo 4 — Primeiro acesso

1. Abra o link do GitHub Pages.
2. Cole a **Project URL** e a **anon key** que você guardou no Passo 2.
3. Clique em "Salvar e conectar". Pronto — os dados agora ficam no Supabase, e não se perdem mais.

> Se abrir o sistema em outro computador/navegador, ele vai pedir a URL e a chave de novo (é só colar as mesmas). Isso é o preço de não gravar a chave no código público — considere guardar as duas informações num gerenciador de senhas.

## O que foi melhorado em relação à primeira versão

- **Banco de dados real** (Supabase/PostgreSQL) em vez de um armazenamento que só funcionava dentro do Claude.
- **Acesso online gratuito**, de qualquer dispositivo, via GitHub Pages.
- **Nível de alerta "crítico" (0-15 dias)** separado do "atenção" (16-30 dias), do jeito que você pediu — fica visualmente destacado (laranja-avermelhado) da lista.
- **Campo de contrato vinculado** ao veículo (ex: "33195 - Shopping da Bahia").
- **Campo de tipo de veículo** (carro / moto / carrocinha / outro).
- **Importar CSV**: dá para levar sua planilha atual direto para o banco de dados (colunas: `placa, modelo, tipo, coordenador, contrato, crlv_vencimento, ipva_vencimento`, datas no formato `AAAA-MM-DD`).
- **Exportar CSV**: gera um relatório rápido para mandar pro financeiro ou pro coordenador.
- **Busca** agora também encontra por contrato, além de placa/modelo/coordenador.

## Ideias para próximas versões (não implementadas ainda)

- **Aviso automático por e-mail ou WhatsApp** quando um veículo entrar na faixa "crítico". Dá pra fazer com uma Supabase Edge Function agendada (cron) + um serviço de e-mail (ex: Resend, que também tem plano grátis) — é um passo a mais de configuração, posso te ajudar quando quiser evoluir para isso.
- **Login por usuário** (Supabase Auth), caso mais de uma pessoa vá cadastrar/editar e você queira saber quem alterou o quê.
- **Histórico de alterações** por veículo (quem mudou a data, quando).
- **Dashboard com gráfico** de vencimentos por mês/contrato.
- **Anexar documentos** (foto do CRLV, comprovante de pagamento do IPVA) usando o Supabase Storage (também gratuito até um limite generoso).

## Um ponto de atenção sobre segurança

Como o app não tem login, qualquer pessoa que tenha a URL do seu projeto Supabase **e** a chave anon consegue ler e alterar os dados. Isso é aceitável para um controle pessoal, mas se um dia mais gente for usar, vale considerar ativar o Supabase Auth (login com e-mail/senha) — é a próxima melhoria natural.
