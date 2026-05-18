const sqlite3 = require('sqlite3');
const db = new sqlite3.Database('C:/Users/48856/.openclaw/memory/main.sqlite');

db.serialize(() => {
  // List all tables
  db.all("SELECT name FROM sqlite_master WHERE type='table'", (err, tables) => {
    if (err) { console.error('Table list error:', err); return; }
    console.log('Tables:', JSON.stringify(tables));

    // Inspect memories table schema
    tables.forEach(t => {
      const name = t.name;
      if (name.includes('memory') || name.includes('short') || name.includes('long') || name.includes('dream')) {
        db.all(`PRAGMA table_info(${name})`, (err, cols) => {
          if (err) { console.error('Schema error:', err); return; }
          console.log(`${name} schema:`, JSON.stringify(cols));
        });

        // Count rows
        db.get(`SELECT COUNT(*) as cnt FROM ${name}`, (err, row) => {
          if (err) { console.error('Count error:', err); return; }
          console.log(`${name} count:`, row.cnt);
        });
      }
    });
  });

  // Also dump all table names
  setTimeout(() => db.close(), 2000);
});
