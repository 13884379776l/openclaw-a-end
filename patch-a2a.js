const fs = require('fs');
let code = fs.readFileSync('C:/Users/48856/.openclaw/extensions/a2a-gateway/dist/index.js', 'utf8');

// Simple approach: find and replace the key sections
// 1. Insert startupInline before registerGatewayMethod
const before = '        const grpcPort = config.server.port + 1;\n        api.registerGatewayMethod("a2a.metrics"';
const after = `        const grpcPort = config.server.port + 1;
        // === PATCH: Start HTTP server before registerGatewayMethod calls ===
        (async function startupInline() {
            if (server) { return; }
            try {
                if (quorumManager) { quorumManager.start(); }
                else { discoveryManager?.start(); }
                healthManager?.start();
                await new Promise((resolve, reject) => {
                    server = app.listen(config.server.port, config.server.host, () => {
                        api.logger.info(\`a2a-gateway: HTTP listening on \${config.server.host}:\${config.server.port}\`);
                        console.error(\">>> [A2A_HTTP_BOUND] listening!\");
                        resolve();
                    });
                    server.once('error', reject);
                });
                console.error(\">>> [A2A_SUCCESS] started!\");
            } catch(err) {
                console.error(\">>> [A2A_START_FAIL]\", err?.message || err);
            }
        })();
        // === END PATCH ===
        if (typeof api.registerGatewayMethod !== "function") {
            api.logger.warn("a2a-gateway: registerGatewayMethod unavailable, skipping");
        } else {
            api.registerGatewayMethod("a2a.metrics"`;

if (code.includes(before)) {
    code = code.replace(before, after);
    console.log('Step 1: Added startupInline and guard');
} else {
    console.log('Step 1: Already patched or not found');
}

// 2. Close the else block before registerService
const lines = code.split('\n');

// Find the line with "api.logger.warn" about registerService
for (let i = 0; i < lines.length; i++) {
    if (lines[i].includes('about to call registerService')) {
        lines[i] = lines[i].replace('api.logger.warn("a2a-gateway: about to call registerService', '        } // end else\n        api.logger.warn("a2a-gateway: about to call registerService');
        // Also wrap registerService with if check
        for (let j = i+1; j < Math.min(i+10, lines.length); j++) {
            if (lines[j].includes('api.registerService({')) {
                lines[j] = lines[j].replace('api.registerService({', '        if (typeof api.registerService === "function") {\n            api.registerService({');
                break;
            }
        }
        break;
    }
}

// 3. Add closing brace before the final };
for (let i = lines.length - 1; i >= 0; i--) {
    if (lines[i].trim() === '};') {
        lines.splice(i, 0, '        } // end if registerService');
        break;
    }
}

fs.writeFileSync('C:/Users/48856/.openclaw/extensions/a2a-gateway/dist/index.js', lines.join('\n'));
console.log('Done!');
