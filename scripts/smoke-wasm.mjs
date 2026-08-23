import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import vm from 'node:vm';
import { createRequire } from 'node:module';

const webDir = path.resolve(process.argv[2] || 'build/web');
const modulePath = path.join(webDir, 'mdli.js');

for (const file of ['index.html', 'app.js', 'sw.js', 'manifest.json', 'mdli.js', 'mdli.wasm', 'mdli.data']) {
    assert.ok(fs.statSync(path.join(webDir, file)).size > 0, `${file} is missing or empty`);
}

const context = {
    console,
    __dirname: webDir,
    __filename: modulePath,
    require: createRequire(modulePath),
    process,
    Buffer,
    setTimeout,
    clearTimeout,
    TextDecoder,
    TextEncoder
};
context.globalThis = context;
vm.createContext(context);
vm.runInContext(fs.readFileSync(modulePath, 'utf8'), context, { filename: modulePath });

assert.equal(typeof context.createMDLI, 'function', 'createMDLI factory is not exported');
const module = await context.createMDLI({ locateFile: (file) => path.join(webDir, file) });

for (const game of ['mdlzork_771212', 'mdlzork_780124', 'mdlzork_791211', 'mdlzork_810722']) {
    const save = `/game/${game}/MDL/MADADV.SAVE`;
    assert.ok(module.FS.stat(save).size >= 100, `${save} is not preloaded`);
}

assert.equal(typeof module.ccall, 'function');
assert.equal(typeof module.FS.readFile, 'function');
console.log('WASM smoke test passed');
