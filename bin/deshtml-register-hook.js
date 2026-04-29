#!/usr/bin/env node
// deshtml-register-hook — idempotent register / unregister of the SessionStart
// update-check hook in ~/.claude/settings.json.
// Usage: node deshtml-register-hook.js <register|unregister> [settingsPath]
// Atomic write; tolerates missing or malformed settings.json (logs and exits 0).

'use strict';

const fs = require('fs');
const path = require('path');
const os = require('os');

const action = process.argv[2];
const settingsPath = process.argv[3] || path.join(os.homedir(), '.claude', 'settings.json');

if (!['register', 'unregister'].includes(action)) {
  console.error('Usage: deshtml-register-hook.js <register|unregister> [settingsPath]');
  process.exit(2);
}

const HOOK_PATH = path.join(os.homedir(), '.claude', 'hooks', 'deshtml-check-update.js');
const HOOK_CMD = `node "${HOOK_PATH}"`;

let settings = {};
if (fs.existsSync(settingsPath)) {
  try {
    settings = JSON.parse(fs.readFileSync(settingsPath, 'utf8'));
    if (typeof settings !== 'object' || settings === null) settings = {};
  } catch (e) {
    console.error(`deshtml: could not parse ${settingsPath} — leaving untouched.`);
    process.exit(0);
  }
}

settings.hooks = settings.hooks || {};
settings.hooks.SessionStart = settings.hooks.SessionStart || [];

const isOurs = (entry) => {
  if (!entry || !Array.isArray(entry.hooks)) return false;
  return entry.hooks.some(h => h && typeof h.command === 'string' && h.command.includes('deshtml-check-update.js'));
};

if (action === 'register') {
  if (!settings.hooks.SessionStart.some(isOurs)) {
    settings.hooks.SessionStart.push({
      hooks: [{ type: 'command', command: HOOK_CMD }],
    });
  }
} else {
  settings.hooks.SessionStart = settings.hooks.SessionStart.filter(e => !isOurs(e));
  if (settings.hooks.SessionStart.length === 0) delete settings.hooks.SessionStart;
  if (Object.keys(settings.hooks).length === 0) delete settings.hooks;
}

fs.mkdirSync(path.dirname(settingsPath), { recursive: true });
const tmp = `${settingsPath}.tmp.${process.pid}`;
fs.writeFileSync(tmp, JSON.stringify(settings, null, 2));
fs.renameSync(tmp, settingsPath);
console.log(`deshtml: ${action} hook ✓`);
