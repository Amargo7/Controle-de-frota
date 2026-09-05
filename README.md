# Controle-de-frota
Sistema simples para controlar o vencimento de CRLV e IPVA da frota de veículos da empresa, com aviso antecipado (10-15 dias) antes do vencimento
[index.html](https://github.com/user-attachments/files/31855984/index.html)
<!DOCTYPE html>
<html lang="pt-BR">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
<title>Controle de Frota</title>
<script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>
<style>
  :root {
    --graphite: #1C2733;
    --graphite-soft: #2A3644;
    --amber: #C9812E;
    --amber-bg: #FBF0DF;
    --critico: #D6491F;
    --critico-bg: #FBE3DA;
    --green: #2F7D5C;
    --green-bg: #E7F3ED;
    --red: #B23A32;
    --red-bg: #FBEAE8;
    --grey: #6B7280;
    --grey-bg: #EEF0F2;
    --paper: #FAF9F7;
    --card: #FFFFFF;
    --line: #E4E1DA;
    --text: #22262B;
  }
  * { box-sizing: border-box; }
  body {
    font-family: 'Inter', -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
    color: var(--text);
    background: var(--paper);
    min-height: 100vh;
    margin: 0;
    padding: 28px 20px 60px;
  }

  .fr-wrap { max-width: 1080px; margin: 0 auto; }

  .fr-header {
    display: flex; justify-content: space-between; align-items: flex-end;
    flex-wrap: wrap; gap: 14px; margin-bottom: 22px;
  }
  .fr-title { font-size: 24px; font-weight: 700; letter-spacing: -0.01em; color: var(--graphite); margin: 0; }
  .fr-sub { font-size: 13.5px; color: var(--grey); margin: 4px 0 0; }
  .fr-header-actions { display: flex; gap: 8px; flex-wrap: wrap; }

  button { font-family: inherit; }
  .fr-add-btn {
    background: var(--graphite); color: #fff; border: none;
    padding: 10px 18px; border-radius: 8px; font-size: 13.5px; font-weight: 600;
    cursor: pointer; transition: background 0.15s ease;
  }
  .fr-add-btn:hover { background: var(--graphite-soft); }
  .fr-ghost-btn {
    background: transparent; color: var(--graphite); border: 1px solid var(--line);
    padding: 10px 16px; border-radius: 8px; font-size: 13px; font-weight: 600; cursor: pointer;
  }
  .fr-ghost-btn:hover { border-color: var(--graphite); }

  .fr-stats { display: grid; grid-template-columns: repeat(5, 1fr); gap: 10px; margin-bottom: 20px; }
  .fr-stat { background: var(--card); border: 1px solid var(--line); border-radius: 10px; padding: 14px 16px; }
  .fr-stat .num { font-size: 22px; font-weight: 700; line-height: 1; color: var(--graphite); }
  .fr-stat .lbl { font-size: 12px; color: var(--grey); margin-top: 6px; }
  .fr-stat.vencido .num { color: var(--red); }
  .fr-stat.critico .num { color: var(--critico); }
  .fr-stat.atencao .num { color: var(--amber); }
  .fr-stat.ok .num { color: var(--green); }

  .fr-controls { display: flex; gap: 10px; margin-bottom: 14px; flex-wrap: wrap; }
  .fr-search, .fr-filter {
    border: 1px solid var(--line); background: var(--card); border-radius: 8px;
    padding: 9px 12px; font-size: 13.5px; color: var(--text);
  }
  .fr-search { flex: 1; min-width: 220px; }
  .fr-filter { min-width: 190px; }

  .fr-table-wrap { background: var(--card); border: 1px solid var(--line); border-radius: 12px; overflow: hidden; }
  table.fr-table { width: 100%; border-collapse: collapse; font-size: 13.5px; }
  table.fr-table th {
    text-align: left; font-size: 11.5px; color: var(--grey); font-weight: 600;
    padding: 12px 14px; border-bottom: 1px solid var(--line); background: #FBFAF8;
  }
  table.fr-table td { padding: 12px 14px; border-bottom: 1px solid var(--line); vertical-align: middle; }
  table.fr-table tr:last-child td { border-bottom: none; }
  .fr-placa { font-weight: 700; color: var(--graphite); }
  .fr-modelo { color: var(--grey); font-size: 12.5px; }
  .fr-contrato { font-size: 12px; color: var(--grey); margin-top: 2px; }

  .fr-badge {
    display: inline-flex; align-items: center; gap: 6px; padding: 4px 9px;
    border-radius: 999px; font-size: 12px; font-weight: 600; white-space: nowrap;
  }
  .fr-badge.vencido { background: var(--red-bg); color: var(--red); }
  .fr-badge.critico { background: var(--critico-bg); color: var(--critico); }
  .fr-badge.atencao { background: var(--amber-bg); color: var(--amber); }
  .fr-badge.ok { background: var(--green-bg); color: var(--green); }
  .fr-badge.sem { background: var(--grey-bg); color: var(--grey); }
  .fr-date { font-size: 12px; color: var(--grey); margin-top: 3px; }

  .fr-actions { display: flex; gap: 6px; }
  .fr-icon-btn {
    background: transparent; border: 1px solid var(--line); border-radius: 6px;
    padding: 5px 9px; font-size: 12px; cursor: pointer; color: var(--grey);
  }
  .fr-icon-btn:hover { border-color: var(--graphite); color: var(--graphite); }
  .fr-icon-btn.del:hover { border-color: var(--red); color: var(--red); }

  .fr-empty { padding: 50px 20px; text-align: center; color: var(--grey); font-size: 13.5px; }
  .fr-error { padding: 14px 16px; background: var(--red-bg); color: var(--red); border-radius: 10px; margin-bottom: 16px; font-size: 13px; }

  .fr-overlay {
    position: fixed; inset: 0; background: rgba(20,24,28,0.45);
    display: flex; align-items: center; justify-content: center; z-index: 999; padding: 20px;
  }
  .fr-modal { background: var(--card); border-radius: 14px; padding: 24px; width: 100%; max-width: 440px; box-shadow: 0 20px 50px rgba(0,0,0,0.2); max-height: 90vh; overflow-y: auto; }
  .fr-modal h3 { margin: 0 0 6px; font-size: 17px; color: var(--graphite); }
  .fr-modal p.fr-modal-note { margin: 0 0 16px; font-size: 12.5px; color: var(--grey); }
  .fr-field { margin-bottom: 12px; }
  .fr-field label { display: block; font-size: 12px; color: var(--grey); margin-bottom: 5px; font-weight: 600; }
  .fr-field input, .fr-field select {
    width: 100%; border: 1px solid var(--line); border-radius: 7px;
    padding: 9px 11px; font-size: 13.5px; background: var(--paper); font-family: inherit;
  }
  .fr-field input:focus, .fr-field select:focus { outline: 2px solid var(--graphite-soft); outline-offset: 1px; }
  .fr-row2 { display: grid; grid-template-columns: 1fr 1fr; gap: 10px; }
  .fr-modal-actions { display: flex; justify-content: flex-end; gap: 8px; margin-top: 18px; }
  .fr-btn-secondary { background: transparent; border: 1px solid var(--line); border-radius: 8px; padding: 9px 16px; font-size: 13px; cursor: pointer; color: var(--text); }
  .fr-btn-primary { background: var(--graphite); border: none; border-radius: 8px; padding: 9px 16px; font-size: 13px; cursor: pointer; color: #fff; font-weight: 600; }

  .fr-loading { padding: 60px; text-align: center; color: var(--grey); font-size: 13.5px; }

  @media (max-width: 760px) {
    .fr-stats { grid-template-columns: repeat(2, 1fr); }
    .fr-row2 { grid-template-columns: 1fr; }
    table.fr-table thead { display: none; }
    table.fr-table, table.fr-table tbody, table.fr-table tr, table.fr-table td { display: block; width: 100%; }
    table.fr-table tr { padding: 12px 14px; border-bottom: 1px solid var(--line); }
    table.fr-table td { border: none; padding: 4px 0; }
    .fr-actions { margin-top: 8px; }
  }
</style>
</head>
<body>
<div id="frota-app"></div>

<script>
(function () {
  const root = document.getElementById('frota-app');
  const CFG_KEY = 'frota-supabase-config';

  let state = {
    loading: true,
    booting: true,
    config: null,
    client: null,
    vehicles: [],
    search: '',
    filter: 'todos',
    modal: null,
    error: null,
  };

  // ---------- utilidades de data / status ----------
  function daysUntil(dateStr) {
    if (!dateStr) return null;
    const today = new Date(); today.setHours(0, 0, 0, 0);
    const d = new Date(dateStr + 'T00:00:00');
    return Math.round((d - today) / 86400000);
  }

  // vencido: já passou | critico: 0-15 dias | atencao: 16-30 dias | ok: mais de 30 | sem: sem data
  function statusOf(dateStr) {
    if (!dateStr) return 'sem';
    const days = daysUntil(dateStr);
    if (days < 0) return 'vencido';
    if (days <= 15) return 'critico';
    if (days <= 30) return 'atencao';
    return 'ok';
  }

  function statusLabel(dateStr) {
    const s = statusOf(dateStr);
    const days = daysUntil(dateStr);
    if (s === 'sem') return 'Sem data';
    if (s === 'vencido') return `Vencido há ${Math.abs(days)}d`;
    if (s === 'critico') return days === 0 ? 'Vence hoje' : `Vence em ${days}d`;
    if (s === 'atencao') return `Vence em ${days}d`;
    return 'Em dia';
  }

  function fmtDate(dateStr) {
    if (!dateStr) return '—';
    const [y, m, d] = dateStr.split('-');
    return `${d}/${m}/${y}`;
  }

  function worstStatus(v) {
    const order = { vencido: 4, critico: 3, atencao: 2, ok: 1, sem: 0 };
    const a = statusOf(v.crlv_vencimento), b = statusOf(v.ipva_vencimento);
    return order[a] >= order[b] ? a : b;
  }

  function tipoLabel(t) {
    return { carro: 'Carro', moto: 'Moto', carrocinha: 'Carrocinha', outro: 'Outro' }[t] || '—';
  }

  // ---------- configuração do Supabase ----------
  function loadConfig() {
    try {
      const raw = localStorage.getItem(CFG_KEY);
      return raw ? JSON.parse(raw) : null;
    } catch (e) { return null; }
  }

  function saveConfig(cfg) {
    localStorage.setItem(CFG_KEY, JSON.stringify(cfg));
  }

  function initClient() {
    if (!state.config) return;
    state.client = supabase.createClient(state.config.url, state.config.anonKey);
  }

  // ---------- dados ----------
  async function loadData() {
    if (!state.client) return;
    state.loading = true; state.error = null; render();
    const { data, error } = await state.client
      .from('veiculos')
      .select('*')
      .order('criado_em', { ascending: true });
    if (error) {
      state.error = 'Não foi possível carregar os dados: ' + error.message;
      state.vehicles = [];
    } else {
      state.vehicles = data || [];
    }
    state.loading = false;
    render();
  }

  async function saveModal() {
    const m = state.modal;
    if (!m.placa || !m.placa.trim()) { alert('Informe a placa do veículo.'); return; }

    const payload = {
      placa: m.placa.trim().toUpperCase(),
      modelo: m.modelo || null,
      tipo: m.tipo || null,
      coordenador: m.coordenador || null,
      contrato: m.contrato || null,
      crlv_vencimento: m.crlv_vencimento || null,
      ipva_vencimento: m.ipva_vencimento || null,
    };

    let error;
    if (m.id) {
      ({ error } = await state.client.from('veiculos').update(payload).eq('id', m.id));
    } else {
      ({ error } = await state.client.from('veiculos').insert([payload]));
    }

    if (error) {
      alert('Erro ao salvar: ' + error.message);
      return;
    }
    state.modal = null;
    await loadData();
  }

  async function deleteVehicle(id) {
    if (!confirm('Remover este veículo do controle?')) return;
    const { error } = await state.client.from('veiculos').delete().eq('id', id);
    if (error) { alert('Erro ao excluir: ' + error.message); return; }
    await loadData();
  }

  function openModal(vehicle) {
    state.modal = vehicle
      ? { ...vehicle }
      : { id: null, placa: '', modelo: '', tipo: 'carro', coordenador: '', contrato: '', crlv_vencimento: '', ipva_vencimento: '' };
    render();
  }
  function closeModal() { state.modal = null; render(); }
  function updateModalField(field, value) { state.modal[field] = value; }

  // ---------- exportar / importar CSV ----------
  function csvEscape(v) {
    const s = (v ?? '').toString();
    return /[",\n]/.test(s) ? '"' + s.replace(/"/g, '""') + '"' : s;
  }

  function exportCsv() {
    const headers = ['placa', 'modelo', 'tipo', 'coordenador', 'contrato', 'crlv_vencimento', 'ipva_vencimento'];
    const lines = [headers.join(',')];
    state.vehicles.forEach(v => {
      lines.push(headers.map(h => csvEscape(v[h])).join(','));
    });
    const blob = new Blob([lines.join('\n')], { type: 'text/csv;charset=utf-8' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `frota-${new Date().toISOString().slice(0, 10)}.csv`;
    document.body.appendChild(a); a.click(); document.body.removeChild(a);
    URL.revokeObjectURL(url);
  }

  function parseCsv(text) {
    const lines = text.split(/\r?\n/).filter(l => l.trim().length);
    if (!lines.length) return [];
    const headers = lines[0].split(',').map(h => h.trim());
    return lines.slice(1).map(line => {
      const cells = [];
      let cur = '', inQuotes = false;
      for (let i = 0; i < line.length; i++) {
        const c = line[i];
        if (inQuotes) {
          if (c === '"' && line[i + 1] === '"') { cur += '"'; i++; }
          else if (c === '"') { inQuotes = false; }
          else cur += c;
        } else {
          if (c === '"') inQuotes = true;
          else if (c === ',') { cells.push(cur); cur = ''; }
          else cur += c;
        }
      }
      cells.push(cur);
      const obj = {};
      headers.forEach((h, i) => obj[h] = (cells[i] || '').trim());
      return obj;
    });
  }

  async function importCsv(file) {
    const text = await file.text();
    const rows = parseCsv(text);
    if (!rows.length) { alert('Nenhuma linha encontrada no arquivo.'); return; }
    const payload = rows
      .filter(r => r.placa)
      .map(r => ({
        placa: r.placa.toUpperCase(),
        modelo: r.modelo || null,
        tipo: r.tipo || null,
        coordenador: r.coordenador || null,
        contrato: r.contrato || null,
        crlv_vencimento: r.crlv_vencimento || null,
        ipva_vencimento: r.ipva_vencimento || null,
      }));
    if (!confirm(`Importar ${payload.length} veículo(s) para o banco de dados?`)) return;
    const { error } = await state.client.from('veiculos').insert(payload);
    if (error) { alert('Erro ao importar: ' + error.message); return; }
    await loadData();
  }

  // ---------- filtro / busca ----------
  function filteredSorted() {
    const q = state.search.toLowerCase();
    let list = state.vehicles.filter(v => {
      const matchesSearch = !q
        || (v.placa || '').toLowerCase().includes(q)
        || (v.modelo || '').toLowerCase().includes(q)
        || (v.coordenador || '').toLowerCase().includes(q)
        || (v.contrato || '').toLowerCase().includes(q);
      const st = worstStatus(v);
      const matchesFilter = state.filter === 'todos' || st === state.filter;
      return matchesSearch && matchesFilter;
    });
    list.sort((a, b) => {
      const da = Math.min(daysUntil(a.crlv_vencimento) ?? 9999, daysUntil(a.ipva_vencimento) ?? 9999);
      const db = Math.min(daysUntil(b.crlv_vencimento) ?? 9999, daysUntil(b.ipva_vencimento) ?? 9999);
      return da - db;
    });
    return list;
  }

  // ---------- render ----------
  function renderConfigScreen() {
    const cfg = state.config || { url: '', anonKey: '' };
    root.innerHTML = `
      <div class="fr-wrap" style="max-width:480px;">
        <div class="fr-header"><div>
          <h1 class="fr-title">Controle de Frota</h1>
          <p class="fr-sub">Conecte ao seu banco de dados Supabase para começar</p>
        </div></div>
        <div class="fr-table-wrap" style="padding:22px;">
          <div class="fr-field">
            <label>URL do projeto Supabase</label>
            <input id="cfg-url" type="text" placeholder="https://xxxxx.supabase.co" value="${cfg.url}" />
          </div>
          <div class="fr-field">
            <label>Chave anon (public)</label>
            <input id="cfg-key" type="text" placeholder="eyJhbGciOi..." value="${cfg.anonKey}" />
          </div>
          <p class="fr-modal-note">Essas informações ficam salvas só neste navegador (localStorage), nunca no código do projeto. Veja o README para saber onde encontrá-las no painel do Supabase.</p>
          <button class="fr-add-btn" id="cfg-save" style="width:100%;">Salvar e conectar</button>
        </div>
      </div>
    `;
    document.getElementById('cfg-save').addEventListener('click', () => {
      const url = document.getElementById('cfg-url').value.trim();
      const anonKey = document.getElementById('cfg-key').value.trim();
      if (!url || !anonKey) { alert('Preencha os dois campos.'); return; }
      state.config = { url, anonKey };
      saveConfig(state.config);
      state.booting = false;
      initClient();
      loadData();
    });
  }

  function renderList() {
    const container = document.getElementById('fr-list-container');
    if (!container) return;
    const list = filteredSorted();
    const total = state.vehicles.length;

    container.innerHTML = list.length === 0 ? `
      <div class="fr-empty">
        ${total === 0 ? 'Nenhum veículo cadastrado ainda. Clique em "Adicionar veículo" para começar.' : 'Nenhum veículo encontrado com esse filtro.'}
      </div>
    ` : `
      <table class="fr-table">
        <thead><tr>
          <th>Veículo</th><th>Coordenador / contrato</th><th>CRLV</th><th>IPVA</th><th></th>
        </tr></thead>
        <tbody>
          ${list.map(v => `
            <tr>
              <td><div class="fr-placa">${v.placa || '—'}</div><div class="fr-modelo">${tipoLabel(v.tipo)}${v.modelo ? ' · ' + v.modelo : ''}</div></td>
              <td>${v.coordenador || '—'}<div class="fr-contrato">${v.contrato || ''}</div></td>
              <td><span class="fr-badge ${statusOf(v.crlv_vencimento)}">${statusLabel(v.crlv_vencimento)}</span><div class="fr-date">${fmtDate(v.crlv_vencimento)}</div></td>
              <td><span class="fr-badge ${statusOf(v.ipva_vencimento)}">${statusLabel(v.ipva_vencimento)}</span><div class="fr-date">${fmtDate(v.ipva_vencimento)}</div></td>
              <td><div class="fr-actions">
                <button class="fr-icon-btn edit" data-id="${v.id}">Editar</button>
                <button class="fr-icon-btn del" data-id="${v.id}">Excluir</button>
              </div></td>
            </tr>
          `).join('')}
        </tbody>
      </table>
    `;

    container.querySelectorAll('.fr-icon-btn.edit').forEach(btn => {
      btn.addEventListener('click', () => openModal(state.vehicles.find(x => x.id === btn.dataset.id)));
    });
    container.querySelectorAll('.fr-icon-btn.del').forEach(btn => {
      btn.addEventListener('click', () => deleteVehicle(btn.dataset.id));
    });
  }

  function render() {
    if (state.booting) { renderConfigScreen(); return; }
    if (state.loading) { root.innerHTML = '<div class="fr-loading">Carregando controle de frota…</div>'; return; }

    const total = state.vehicles.length;
    const vencidos = state.vehicles.filter(v => worstStatus(v) === 'vencido').length;
    const criticos = state.vehicles.filter(v => worstStatus(v) === 'critico').length;
    const atencao = state.vehicles.filter(v => worstStatus(v) === 'atencao').length;
    const emDia = state.vehicles.filter(v => worstStatus(v) === 'ok').length;

    root.innerHTML = `
      <div class="fr-wrap">
        <div class="fr-header">
          <div>
            <h1 class="fr-title">Controle de Frota</h1>
            <p class="fr-sub">Vencimentos de CRLV e IPVA por veículo</p>
          </div>
          <div class="fr-header-actions">
            <button class="fr-ghost-btn" id="fr-export">Exportar CSV</button>
            <button class="fr-ghost-btn" id="fr-import-btn">Importar planilha (CSV)</button>
            <input type="file" id="fr-import-file" accept=".csv" style="display:none" />
            <button class="fr-ghost-btn" id="fr-reconfig">Trocar banco de dados</button>
            <button class="fr-add-btn" id="fr-add">+ Adicionar veículo</button>
          </div>
        </div>

        ${state.error ? `<div class="fr-error">${state.error}</div>` : ''}

        <div class="fr-stats">
          <div class="fr-stat"><div class="num">${total}</div><div class="lbl">Veículos cadastrados</div></div>
          <div class="fr-stat vencido"><div class="num">${vencidos}</div><div class="lbl">Vencidos</div></div>
          <div class="fr-stat critico"><div class="num">${criticos}</div><div class="lbl">Críticos (0-15 dias)</div></div>
          <div class="fr-stat atencao"><div class="num">${atencao}</div><div class="lbl">Atenção (16-30 dias)</div></div>
          <div class="fr-stat ok"><div class="num">${emDia}</div><div class="lbl">Em dia</div></div>
        </div>

        <div class="fr-controls">
          <input class="fr-search" id="fr-search" type="text" placeholder="Buscar por placa, modelo, coordenador ou contrato…" value="${state.search}" />
          <select class="fr-filter" id="fr-filter">
            <option value="todos" ${state.filter === 'todos' ? 'selected' : ''}>Todos os status</option>
            <option value="vencido" ${state.filter === 'vencido' ? 'selected' : ''}>Vencidos</option>
            <option value="critico" ${state.filter === 'critico' ? 'selected' : ''}>Críticos (0-15 dias)</option>
            <option value="atencao" ${state.filter === 'atencao' ? 'selected' : ''}>Atenção (16-30 dias)</option>
            <option value="ok" ${state.filter === 'ok' ? 'selected' : ''}>Em dia</option>
            <option value="sem" ${state.filter === 'sem' ? 'selected' : ''}>Sem data</option>
          </select>
        </div>

        <div class="fr-table-wrap" id="fr-list-container"></div>
      </div>

      ${state.modal ? `
        <div class="fr-overlay" id="fr-overlay">
          <div class="fr-modal">
            <h3>${state.modal.id ? 'Editar veículo' : 'Adicionar veículo'}</h3>
            <p class="fr-modal-note">Prazo de aviso crítico: 0 a 15 dias antes do vencimento.</p>
            <div class="fr-field"><label>Placa</label><input id="m-placa" type="text" value="${state.modal.placa || ''}" placeholder="ABC-1234" /></div>
            <div class="fr-row2">
              <div class="fr-field"><label>Tipo</label>
                <select id="m-tipo">
                  <option value="carro" ${state.modal.tipo === 'carro' ? 'selected' : ''}>Carro</option>
                  <option value="moto" ${state.modal.tipo === 'moto' ? 'selected' : ''}>Moto</option>
                  <option value="carrocinha" ${state.modal.tipo === 'carrocinha' ? 'selected' : ''}>Carrocinha</option>
                  <option value="outro" ${state.modal.tipo === 'outro' ? 'selected' : ''}>Outro</option>
                </select>
              </div>
              <div class="fr-field"><label>Modelo / ano</label><input id="m-modelo" type="text" value="${state.modal.modelo || ''}" placeholder="Ex: Onix 2022" /></div>
            </div>
            <div class="fr-field"><label>Coordenador responsável</label><input id="m-coordenador" type="text" value="${state.modal.coordenador || ''}" placeholder="Nome do coordenador" /></div>
            <div class="fr-field"><label>Contrato vinculado</label><input id="m-contrato" type="text" value="${state.modal.contrato || ''}" placeholder="Ex: 33195 - Shopping da Bahia" /></div>
            <div class="fr-row2">
              <div class="fr-field"><label>Vencimento do CRLV</label><input id="m-crlv" type="date" value="${state.modal.crlv_vencimento || ''}" /></div>
              <div class="fr-field"><label>Vencimento do IPVA</label><input id="m-ipva" type="date" value="${state.modal.ipva_vencimento || ''}" /></div>
            </div>
            <div class="fr-modal-actions">
              <button class="fr-btn-secondary" id="fr-cancel">Cancelar</button>
              <button class="fr-btn-primary" id="fr-save">Salvar</button>
            </div>
          </div>
        </div>
      ` : ''}
    `;

    document.getElementById('fr-add')?.addEventListener('click', () => openModal(null));
    document.getElementById('fr-search')?.addEventListener('input', (e) => { state.search = e.target.value; renderList(); });
    document.getElementById('fr-filter')?.addEventListener('change', (e) => { state.filter = e.target.value; renderList(); });
    document.getElementById('fr-export')?.addEventListener('click', exportCsv);
    document.getElementById('fr-import-btn')?.addEventListener('click', () => document.getElementById('fr-import-file').click());
    document.getElementById('fr-import-file')?.addEventListener('change', (e) => {
      if (e.target.files && e.target.files[0]) importCsv(e.target.files[0]);
      e.target.value = '';
    });
    document.getElementById('fr-reconfig')?.addEventListener('click', () => {
      if (!confirm('Isso vai pedir novamente a URL e a chave do Supabase neste navegador. Continuar?')) return;
      state.booting = true;
      render();
    });

    renderList();

    if (state.modal) {
      document.getElementById('fr-cancel').addEventListener('click', closeModal);
      document.getElementById('fr-save').addEventListener('click', saveModal);
      ['placa', 'modelo', 'tipo', 'coordenador', 'contrato', 'crlv_vencimento', 'ipva_vencimento'].forEach(f => {
        const idMap = { crlv_vencimento: 'm-crlv', ipva_vencimento: 'm-ipva' };
        const el = document.getElementById(idMap[f] || 'm-' + f);
        if (el) el.addEventListener('input', (e) => updateModalField(f, e.target.value));
      });
      document.getElementById('fr-overlay').addEventListener('click', (e) => { if (e.target.id === 'fr-overlay') closeModal(); });
    }
  }

  // ---------- boot ----------
  state.config = loadConfig();
  if (state.config) {
    state.booting = false;
    initClient();
    loadData();
  } else {
    render();
  }
})();
</script>
</body>
</html>
