#!/usr/bin/env node
// deshtml-check-update — SessionStart hook.
// Compares installed VERSION against upstream main; prints a one-line notice
// when a newer version is available. Cached for 6h to avoid hammering GitHub.
// Written for Node 18+ (uses built-in https). Fails silently on any error.

'use strict';

const fs = require('fs');
const path = require('path');
const os = require('os');
const https = require('https');

const VERSION_URL = 'https://raw.githubusercontent.com/sperezasis/deshtml/main/VERSION';
const VERSION_FILE = path.join(os.homedir(), '.claude', 'skills', 'deshtml', '.version');
const CACHE_DIR = path.join(os.homedir(), '.cache', 'deshtml');
const CACHE_FILE = path.join(CACHE_DIR, 'update-check.json');
const CACHE_TTL_MS = 6 * 60 * 60 * 1000; // 6h

function isNewer(a, b) {
  const pa = String(a).split('.').map(s => Number(s) || 0);
  const pb = String(b).split('.').map(s => Number(s) || 0);
  for (let i = 0; i < 3; i++) {
    if ((pa[i] || 0) > (pb[i] || 0)) return true;
    if ((pa[i] || 0) < (pb[i] || 0)) return false;
  }
  return false;
}

function readInstalled() {
  try { return fs.readFileSync(VERSION_FILE, 'utf8').trim(); } catch { return null; }
}

function readCache() {
  try {
    const data = JSON.parse(fs.readFileSync(CACHE_FILE, 'utf8'));
    if (Date.now() - data.checkedAt < CACHE_TTL_MS) return data;
  } catch {}
  return null;
}

function writeCache(payload) {
  try {
    fs.mkdirSync(CACHE_DIR, { recursive: true });
    fs.writeFileSync(CACHE_FILE, JSON.stringify(payload));
  } catch {}
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
  const installed = readInstalled();
  if (!installed) return;

  let latest;
  const cached = readCache();
  if (cached && cached.latest) {
    latest = cached.latest;
  } else {
    latest = await fetchLatest(2000);
    if (latest) writeCache({ latest, checkedAt: Date.now() });
  }
  if (!latest || !isNewer(latest, installed)) return;

  // Claude Code 2.x suppresses plain stdout from SessionStart hooks. The official
  // user-visible mechanism is the `hookSpecificOutput.additionalContext` JSON form,
  // which Claude Code injects as a system message at session start.
  const message =
    `\u{1F4E6} deshtml v${latest} available (you have v${installed}). ` +
    `Update: curl -fsSL https://raw.githubusercontent.com/sperezasis/deshtml/main/bin/install.sh | bash`;

  process.stdout.write(JSON.stringify({
    hookSpecificOutput: {
      hookEventName: 'SessionStart',
      additionalContext: message,
    },
  }));
})();
