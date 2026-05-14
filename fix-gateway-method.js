const fs = require('fs');
let code = fs.readFileSync('C:/Users/48856/.openclaw/extensions/a2a-gateway/dist/index.js', 'utf8');

// OpenClaw 5.7 registerGatewayMethod callback signature:
// OLD: ({ params, respond }) => { respond(true, data); }
// NEW: async (opts) => { return { ok: true, ...data }; }
// opts structure in 5.7: { params, respond(ok, data) } is wrapped by OpenClaw

// The issue is that 5.7 passes opts differently. Let's check what browser.request uses:
// api.registerGatewayMethod("browser.request", async (opts) => { ... return await handle... }, { scope: "operator.admin" });
// So 5.7 expects: async (opts) => { return result; }
// where result is { ok: boolean, ...data }

// A2A plugin uses: ({ params, respond }) => { respond(true, { ... }); }
// In 5.7, the callback receives opts, and params is opts.params
// respond is NOT provided - instead we return { ok, ...data }

// Fix: Change all registerGatewayMethod callbacks to return { ok, ...data } instead of calling respond()

// Pattern 1: respond(true, { ... })
code = code.replace(
  /api\.registerGatewayMethod\("a2a\.metrics", \(\{ respond \}\) => \{\s*respond\(true, \{\s*metrics: telemetry\.snapshot\(\),?\s*\}\);?\s*\}\);/gs,
  'api.registerGatewayMethod("a2a.metrics", async (opts) => {\n            return { ok: true, metrics: telemetry.snapshot() };\n        });'
);

// Pattern 2: respond(false, { error: ... })
code = code.replace(
  /api\.registerGatewayMethod\("a2a\.audit", \(\{ params, respond \}\) => \{(\s+)\1?const payload = asObject\(params\);(\s+)\1?const count = Math\.min\(Math\.max\(1, asNumber\(payload\.count, 50\)\), 500\);(\s+)\1?auditLogger(\s+)\1?\.tail\(count\)(\s+)\1?\.then\(\(entries\) => respond\(true, \{ entries, count: entries\.length \}\)\)(\s+)\1?\.catch\(\(error\) => respond\(false, \{ error: String\(error\?\.message \|\| error\) \}\)\);(\s+)\1?\}\);/gs,
  'api.registerGatewayMethod("a2a.audit", async (opts) => {\n            const payload = asObject(opts.params);\n            const count = Math.min(Math.max(1, asNumber(payload.count, 50)), 500);\n            try {\n                const entries = await auditLogger.tail(count);\n                return { ok: true, entries, count: entries.length };\n            } catch(error) {\n                return { ok: false, error: String(error?.message || error) };\n            }\n        });'
);

console.log('Replacements made:', code.includes('respond(true,') ? 'NO - still has old pattern' : 'YES - fixed');

// Check for remaining respond() calls
const respondCalls = (code.match(/respond\(/g) || []).length;
console.log('Remaining respond() calls:', respondCalls);

fs.writeFileSync('C:/Users/48856/.openclaw/extensions/a2a-gateway/dist/index.js', code);
console.log('Done!');
