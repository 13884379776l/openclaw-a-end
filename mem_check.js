const path = require('path');
const dbPath = path.join(process.env.USERPROFILE, '.openclaw', 'memory', 'main.sqlite');

// Try better-sqlite3 first, then try the built-in node sqlite
let DB;
try {
  const bs = require('better-sqlite3');
  DB = new bs(dbPath);
  console.log('Using better-sqlite3');
} catch(e) {
  console.error('better-sqlite3 not available:', e.message);
  console.log('Trying to read file directly...');
  const fs = require('fs');
  const buf = fs.readFileSync(dbPath);
  const headers = buf.slice(0, 100).toString('hex');
  console.log('File size:', buf.length);
  console.log('Header:', buf.slice(0, 16).toString());
  process.exit(0);
}

// List tables
const tables = DB.prepare("SELECT name FROM sqlite_master WHERE type='table'").all();
console.log('Tables:', JSON.stringify(tables));

tables.forEach(t => {
  const name = t.name;
  const info = DB.prepare(`PRAGMA table_info(${name})`).all();
  console.log(`${name} columns:`, JSON.stringify(info));
  const count = DB.prepare(`SELECT COUNT(*) as cnt FROM ${name}`).get();
  console.log(`${name} count:`, count.cnt);
});

DB.close();
