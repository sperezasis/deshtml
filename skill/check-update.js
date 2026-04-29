#!/usr/bin/env node
// deshtml update checker — invoked by SKILL.md Step 0.
// Prints a one-line notice when a newer version is available; silent otherwise.
// Cache: ~/.cache/deshtml/update-check.json with 6h TTL.
// Falls back to network fetch if cache is missing or stale; 2s timeout.

'use strict';

const fs = require('fs');
const path = require('path');
const os = require('os');
const https = require('https');

const VERSION_URL = 'https://raw.githubusercontent.com/sperezasis/deshtml/main/VERSION';
const VERSION_FILE = path.join(os.homedir(), '.claude', 'skills', 'deshtml', '.version');
const CACHE_DIR = path.join(os.homedir(), '.cache', 'deshtml');
const CACHE_FILE = path.join(CACHE_DIR, 'update-check.json');
const CACHE_TTL_MS = 6 * 60 * 60 * 1000;
const INSTALL_URL = 'https://raw.githubusercontent.com/sperezasis/deshtml/main/bin/install.sh';

function isNewer(a, b) {
  const pa = String(a).split('.').map(s => Number(s) || 0);
  const pb = String(b).split('.').map(s => Number(s) || 0);
  for (let i = 0; i < 3; i++) {
    if ((pa[i] || 0) > (pb[i] || 0)) return true;
    if ((pa[i] || 0) < (pb[i] || 0)) return false;
  }
  return false;
}

function fetchLatest(timeoutMs) {
  return new Promise((resolve) => {
    const req = https.get(VERSION_URL, (res) => {
      if (res.statusCode !== 200) { res.resume(); return resolve(null); }
      let body = '';
      res.on('data', (c) => body += c);
      res.on('end', () => resolve(body.trim()));
    });
    req.on('error', () => resolve(null));
    req.setTimeout(timeoutMs, () => { req.destroy(); resolve(null); });
  });
}

(async () => {
  let installed;
  try { installed = fs.readFileSync(VERSION_FILE, 'utf8').trim(); } catch { return; }
  if (!installed) return;

  let latest;
  try {
    const data = JSON.parse(fs.readFileSync(CACHE_FILE, 'utf8'));
    if (Date.now() - data.checkedAt < CACHE_TTL_MS) latest = data.latest;
  } catch {}

  if (!latest) {
    latest = await fetchLatest(2000);
    if (latest) {
      try {
        fs.mkdirSync(CACHE_DIR, { recursive: true });
        fs.writeFileSync(CACHE_FILE, JSON.stringify({ latest, checkedAt: Date.now() }));
      } catch {}
    }
  }

  if (!latest || !isNewer(latest, installed)) return;

  process.stdout.write(
    `\u{1F4E6} deshtml v${latest} available (you have v${installed}). ` +
    `Update: curl -fsSL ${INSTALL_URL} | bash\n`
  );
})();
