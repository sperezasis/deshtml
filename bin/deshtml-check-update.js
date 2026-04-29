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

function logDebug(msg) {
  try {
    fs.mkdirSync(CACHE_DIR, { recursive: true });
    fs.appendFileSync(path.join(CACHE_DIR, 'last-run.log'),
      `${new Date().toISOString()} ${msg}\n`);
  } catch {}
}

(async () => {
  logDebug('hook fired');
  const installed = readInstalled();
  if (!installed) { logDebug('no .version file — abort'); return; }

  let latest;
  const cached = readCache();
  if (cached && cached.latest) {
    latest = cached.latest;
  } else {
    latest = await fetchLatest(2000);
    if (latest) writeCache({ latest, checkedAt: Date.now() });
  }
  logDebug(`installed=${installed} latest=${latest || '?'}`);
  if (!latest || !isNewer(latest, installed)) { logDebug('no notice needed'); return; }

  // Claude Code 2.x runs SessionStart hooks with stdio captured, so plain
  // stdout/stderr never reach the user's terminal, and `additionalContext`
  // only reaches Claude (the model), not the visible UI. The reliable
  // user-visible channel is /dev/tty: writing there bypasses the captured
  // pipes and reaches the controlling terminal directly. We also include
  // the JSON additionalContext form so Claude knows about the update and
  // can mention it on demand.
  const banner =
    `\n\u{1F4E6} deshtml v${latest} available (you have v${installed}).\n` +
    `   Update: curl -fsSL https://raw.githubusercontent.com/sperezasis/deshtml/main/bin/install.sh | bash\n\n`;

  let ttyOk = false;
  try {
    const fd = fs.openSync('/dev/tty', 'w');
    fs.writeSync(fd, banner);
    fs.closeSync(fd);
    ttyOk = true;
  } catch (e) {
    logDebug(`/dev/tty write failed: ${e && e.code || e}`);
  }
  logDebug(`tty=${ttyOk ? 'ok' : 'fail'} — printed banner`);

  process.stdout.write(JSON.stringify({
    hookSpecificOutput: {
      hookEventName: 'SessionStart',
      additionalContext: banner.trim(),
    },
  }));
})();
