const neuronDebugDashboardHtml = r'''
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Neuron Debug Dashboard</title>
  <style>
    :root {
      --bg: #0f172a;
      --panel: #111827;
      --muted: #94a3b8;
      --text: #e2e8f0;
      --accent: #22d3ee;
      --accent-2: #6366f1;
      --border: #1f2937;
    }
    * { box-sizing: border-box; }
    body {
      margin: 0;
      background: linear-gradient(135deg, #0f172a 0%, #0b1324 100%);
      color: var(--text);
      font-family: "Inter", "Segoe UI", system-ui, -apple-system, sans-serif;
      min-height: 100vh;
    }
    header {
      padding: 28px 32px 12px;
      display: flex;
      align-items: center;
      gap: 16px;
    }
    h1 { margin: 0; font-size: 24px; letter-spacing: -0.02em; }
    .pill {
      padding: 6px 12px;
      border-radius: 999px;
      background: rgba(255,255,255,0.06);
      color: var(--muted);
      font-size: 12px;
      border: 1px solid var(--border);
    }
    .grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
      gap: 16px;
      padding: 0 32px 24px;
    }
    .card {
      background: var(--panel);
      border: 1px solid var(--border);
      border-radius: 14px;
      padding: 16px;
      box-shadow: 0 10px 30px rgba(0,0,0,0.25);
    }
    .card h3 {
      margin: 0 0 8px;
      font-size: 14px;
      letter-spacing: 0.02em;
      color: var(--muted);
      text-transform: uppercase;
    }
    .metric {
      font-size: 26px;
      font-weight: 700;
    }
    .sub { color: var(--muted); font-size: 12px; }
    .list {
      margin: 0; padding: 0; list-style: none;
      display: flex; flex-direction: column; gap: 10px;
    }
    .row {
      display: flex;
      align-items: center;
      justify-content: space-between;
      padding: 12px;
      border-radius: 10px;
      background: rgba(255,255,255,0.03);
      border: 1px solid var(--border);
    }
    .row .title { font-weight: 600; }
    .row .meta { color: var(--muted); font-size: 12px; }
    .badge {
      padding: 4px 10px;
      border-radius: 8px;
      background: rgba(34, 211, 238, 0.12);
      color: var(--accent);
      font-size: 12px;
      border: 1px solid rgba(34, 211, 238, 0.3);
    }
    .timeline {
      max-height: 320px;
      overflow-y: auto;
      display: flex;
      flex-direction: column;
      gap: 10px;
    }
    .chip {
      padding: 4px 8px;
      border-radius: 6px;
      font-size: 12px;
      border: 1px solid var(--border);
      color: var(--muted);
    }
    button {
      background: linear-gradient(120deg, var(--accent), var(--accent-2));
      color: #0f172a;
      border: none;
      padding: 10px 14px;
      border-radius: 10px;
      font-weight: 700;
      cursor: pointer;
      transition: transform 0.1s ease, box-shadow 0.1s ease;
    }
    button:hover { transform: translateY(-1px); box-shadow: 0 10px 25px rgba(34,211,238,0.25); }
    button:active { transform: translateY(0); }
    @media (max-width: 720px) {
      header { flex-direction: column; align-items: flex-start; }
    }
  </style>
</head>
<body>
  <header>
    <div>
      <h1>Neuron Debug Dashboard</h1>
      <div class="pill" id="protocol-pill">Connecting…</div>
    </div>
    <div style="display:flex;gap:10px;flex-wrap:wrap;align-items:center;">
      <input id="search-box" type="search" placeholder="Search signals/computed" style="padding:10px;border-radius:10px;border:1px solid var(--border);background:#0b1224;color:var(--text);min-width:220px;">
      <button id="refresh-btn">Force Snapshot</button>
    </div>
  </header>

  <div class="grid" id="stats-grid">
    <div class="card">
      <h3>Signals</h3>
      <div class="metric" id="signals-count">0</div>
      <div class="sub">Tracked signals</div>
    </div>
    <div class="card">
      <h3>Computed</h3>
      <div class="metric" id="computed-count">0</div>
      <div class="sub">Derived values</div>
    </div>
    <div class="card">
      <h3>Controllers</h3>
      <div class="metric" id="controllers-count">0</div>
      <div class="sub">Active controllers</div>
    </div>
    <div class="card">
      <h3>Events</h3>
      <div class="metric" id="events-count">0</div>
      <div class="sub">Recent history</div>
    </div>
  </div>

  <div class="grid">
    <div class="card">
      <h3>Signals</h3>
      <ul class="list" id="signals-list"></ul>
    </div>
    <div class="card">
      <h3>Computed</h3>
      <ul class="list" id="computed-list"></ul>
    </div>
    <div class="card">
      <h3>Controllers</h3>
      <ul class="list" id="controllers-list"></ul>
    </div>
  </div>

  <div class="grid">
    <div class="card" style="grid-column: 1 / -1;">
      <h3>Event Stream</h3>
      <div class="timeline" id="timeline"></div>
    </div>
  </div>

  <div class="grid">
    <div class="card">
      <h3>Performance</h3>
      <div class="metric" id="fps-current">0</div>
      <div class="sub">FPS (current / avg)</div>
      <div class="chip" id="fps-avg">avg: 0</div>
    </div>
    <div class="card">
      <h3>Memory</h3>
      <div class="metric" id="mem-current">0</div>
      <div class="sub">RSS (current / avg)</div>
      <div class="chip" id="mem-avg">avg: 0</div>
    </div>
    <div class="card">
      <h3>Benchmarks</h3>
      <div class="timeline" id="benchmarks"></div>
    </div>
  </div>

  <script>
    const state = {
      signals: {},
      computed: {},
      controllers: [],
      history: [],
      perSignalHistory: {},
      protocol: 'unknown',
      metrics: {},
      watchList: new Set(),
    };

    const wsProtocol = location.protocol === 'https:' ? 'wss' : 'ws';
    const wsUrl = wsProtocol + '://' + location.host;
    let socket;
    let searchTerm = '';
    let watched = new Set();

    document.getElementById('refresh-btn').addEventListener('click', () => {
      requestSnapshot();
    });

    document.getElementById('search-box').addEventListener('input', (e) => {
      searchTerm = (e.target.value || '').toLowerCase();
      render();
    });

    function connectWs() {
      socket = new WebSocket(wsUrl);
      socket.onopen = () => {
        setStatus('Connected');
      };
      socket.onmessage = (event) => {
        try {
          const msg = JSON.parse(event.data);
          handleMessage(msg);
        } catch (_) {}
      };
      socket.onclose = () => {
        setStatus('Reconnecting…');
        setTimeout(connectWs, 1000);
      };
      socket.onerror = () => {
        socket.close();
      };
    }

    function handleMessage(msg) {
      if (!msg || !msg.type) return;
      if (msg.protocol) state.protocol = msg.protocol;
      if (msg.type === 'snapshot') {
        applySnapshot(msg.data || {});
      } else if (msg.type === 'event') {
        pushEvent(msg.event);
      } else if (msg.type === 'heartbeat') {
        setStatus('Connected · heartbeat');
      }
    }

    function applySnapshot(data) {
      state.signals = data.signals || {};
      state.computed = data.computed || {};
      state.controllers = data.controllers || [];
      state.history = data.history || state.history;
      state.perSignalHistory = data.perSignalHistory || {};
      state.metrics = data.metrics || {};
      render();
      sendWatchList();
    }

    function pushEvent(ev) {
      if (!ev) return;
      state.history.push(ev);
      if (state.history.length > 500) state.history.shift();
      renderTimeline();
      document.getElementById('events-count').textContent = state.history.length;
    }

    async function bootstrap() {
      try {
        const snap = await fetch('/snapshot').then(r => r.json());
        state.protocol = snap.protocol || state.protocol;
        applySnapshot(snap.data || snap);

        const events = await fetch('/events').then(r => r.json());
        state.history = events.history || [];
        renderTimeline();
        setStatus('Ready');
      } catch (e) {
        setStatus('Snapshot failed');
      }
      connectWs();
    }

    function render() {
      document.getElementById('signals-count').textContent = Object.keys(state.signals).length;
      document.getElementById('computed-count').textContent = Object.keys(state.computed).length;
      document.getElementById('controllers-count').textContent = state.controllers.length;
      document.getElementById('events-count').textContent = state.history.length;
      renderList('signals-list', state.signals, 'signals');
      renderList('computed-list', state.computed, 'computed');
      renderControllers();
      renderTimeline();
      renderMetrics();
    }

    function renderList(id, items, type) {
      const list = document.getElementById(id);
      list.innerHTML = '';
      Object.entries(items).forEach(([key, value]) => {
        if (searchTerm && !key.toLowerCase().includes(searchTerm)) return;
        const li = document.createElement('li');
        li.className = 'row';
        const history = state.perSignalHistory[key] || [];
        const spark = buildSparkline(history.map((e) => e.value));
        li.innerHTML = `
          <div>
            <div class="title">${key}</div>
            <div class="meta">${value.type || typeof value}</div>
          </div>
          <div style="display:flex;align-items:center;gap:8px;">
            ${spark}
            <div class="badge">${formatValue(value.value)}</div>
            <input type="checkbox" data-id="${key}" ${state.watchList.has(key) ? 'checked' : ''} title="Watch">
          </div>
        `;
        list.appendChild(li);
      });

      list.querySelectorAll('input[type="checkbox"]').forEach((el) => {
        el.addEventListener('change', (e) => {
          const id = e.target.getAttribute('data-id');
          if (!id) return;
          if (e.target.checked) {
            state.watchList.add(id);
            // Request more history for watched signals
            sendSignalHistoryLimit(id, 200);
            watched.add(id);
          } else {
            state.watchList.delete(id);
            sendSignalHistoryLimit(id, 20);
            watched.delete(id);
          }
          sendWatchList();
        });
      });
    }

    function renderControllers() {
      const list = document.getElementById('controllers-list');
      list.innerHTML = '';
      state.controllers.forEach((controller) => {
        const li = document.createElement('li');
        li.className = 'row';
        li.innerHTML = `
          <div>
            <div class="title">${controller.id}</div>
            <div class="meta">Signals: ${controller.signals ?? controller.signalsCount ?? controller.signals}</div>
          </div>
          <div class="chip">${timeAgo(controller.createdAt)}</div>
        `;
        list.appendChild(li);
      });
    }

    function renderTimeline() {
      const wrap = document.getElementById('timeline');
      wrap.innerHTML = '';
      const items = [...state.history].slice(-100).reverse();
      items.forEach(ev => {
        const row = document.createElement('div');
        row.className = 'row';
        row.innerHTML = `
          <div>
            <div class="title">${ev.id || ''}</div>
            <div class="meta">${ev.type} · ${timeAgo(ev.timestamp)}</div>
          </div>
          <div class="badge">${formatValue(ev.value)}</div>
        `;
        wrap.appendChild(row);
      });
    }

    function renderMetrics() {
      const m = state.metrics || {};
      const fps = m.fps || {};
      const mem = m.memory || {};
      document.getElementById('fps-current').textContent = (fps.current ?? 0).toFixed ? fps.current.toFixed(1) : fps.current || 0;
      document.getElementById('fps-avg').textContent = `avg: ${(fps.average ?? 0).toFixed ? fps.average.toFixed(1) : fps.average || 0}`;
      document.getElementById('mem-current').textContent = mem.current || 0;
      document.getElementById('mem-avg').textContent = `avg: ${mem.average || 0}`;

      const bench = m.benchmarks || {};
      const benchWrap = document.getElementById('benchmarks');
      benchWrap.innerHTML = '';
      Object.entries(bench).forEach(([key, value]) => {
        const row = document.createElement('div');
        row.className = 'row';
        row.innerHTML = `
          <div>
            <div class="title">${key}</div>
            <div class="meta">${JSON.stringify(value)}</div>
          </div>
        `;
        benchWrap.appendChild(row);
      });
    }

    function formatValue(val) {
      if (val === null || val === undefined) return 'null';
      if (typeof val === 'object') return JSON.stringify(val);
      return String(val);
    }

    function timeAgo(ts) {
      if (!ts) return '';
      const now = Date.now();
      const diff = now - Number(ts);
      const sec = Math.floor(diff / 1000);
      if (sec < 60) return sec + 's ago';
      const min = Math.floor(sec / 60);
      if (min < 60) return min + 'm ago';
      const hr = Math.floor(min / 60);
      return hr + 'h ago';
    }

    function setStatus(text) {
      const pill = document.getElementById('protocol-pill');
      pill.textContent = `Protocol ${state.protocol} · ${text}`;
    }

    function requestSnapshot() {
      if (socket && socket.readyState === WebSocket.OPEN) {
        socket.send(JSON.stringify({ type: 'get_snapshot' }));
      } else {
        bootstrap();
      }
    }

    function sendSignalHistoryLimit(id, limit) {
      if (socket && socket.readyState === WebSocket.OPEN) {
        socket.send(JSON.stringify({ type: 'set_signal_history_limit', id, limit }));
      }
    }

    function sendWatchList() {
      if (socket && socket.readyState === WebSocket.OPEN) {
        socket.send(JSON.stringify({ type: 'set_watch_list', ids: Array.from(state.watchList) }));
      }
    }

    function buildSparkline(values) {
      if (!values || values.length === 0) return '<div class="chip">no data</div>';
      const nums = values.map((v) => {
        if (typeof v === 'number') return v;
        const parsed = Number(v);
        return Number.isFinite(parsed) ? parsed : 0;
      });
      const max = Math.max(...nums);
      const min = Math.min(...nums);
      const scale = max === min ? 1 : (max - min);
      const points = nums.map((v, i) => {
        const x = (i / Math.max(nums.length - 1, 1)) * 100;
        const y = 30 - ((v - min) / scale) * 30;
        return `${x},${y}`;
      }).join(' ');
      return `<svg width="100" height="30" viewBox="0 0 100 30" preserveAspectRatio="none">
        <polyline fill="none" stroke="var(--accent)" stroke-width="2" points="${points}" />
      </svg>`;
    }

    bootstrap();
  </script>
</body>
</html>
''';
