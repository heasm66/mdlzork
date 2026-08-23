/**
 * MDL Zork - WebAssembly Terminal Interface
 * Handles WASM module loading and xterm.js integration
 */

class ZorkGame {
    constructor() {
        this.module = null;
        this.terminal = null;
        this.fitAddon = null;
        this.statusEl = document.getElementById('status');
        this.startBtn = document.getElementById('start-btn');
        this.versionSelect = document.getElementById('version-select');
        this.saveBtn = document.getElementById('save-btn');
        this.loadBtn = document.getElementById('load-btn');
        this.exportBtn = document.getElementById('export-btn');
        this.importBtn = document.getElementById('import-btn');

        this.isReady = false;
        this.isRunning = false;
        this.inputBuffer = '';
        this.commandHistory = [];
        this.historyIndex = -1;
        this.currentGamePath = null;
        this.db = null;

        // Game version mappings
        this.gameVersions = {
            'zork-810722': {
                name: 'Zork 1981-07-22 (Final MDL, 585 pts)',
                path: '/game/mdlzork_810722',
                saveFile: 'MDL/MADADV.SAVE',
                description: 'The final MDL version of Zork, split into three parts for Infocom.',
                maxPoints: 585
            },
            'zork-791211': {
                name: 'Zork 1979-12-11 (616 pts)',
                path: '/game/mdlzork_791211',
                saveFile: 'MDL/MADADV.SAVE',
                description: 'The most complete single-file Zork with all puzzles and end-game.',
                maxPoints: 616
            },
            'zork-780124': {
                name: 'Zork 1978-01-24 (Incomplete end-game)',
                path: '/game/mdlzork_780124',
                saveFile: 'MDL/MADADV.SAVE',
                description: 'Early version with partial end-game implementation.',
                maxPoints: null
            },
            'zork-771212': {
                name: 'Zork 1977-12-12 (500 pts, no end-game)',
                path: '/game/mdlzork_771212',
                saveFile: 'MDL/MADADV.SAVE',
                description: 'The earliest surviving playable version of Zork.',
                maxPoints: 500
            }
        };

        this.setupTerminal();
        this.setupEventListeners();
        this.initIndexedDB();
    }

    setupTerminal() {
        this.terminal = new Terminal({
            cursorBlink: true,
            fontSize: 14,
            fontFamily: '"Courier New", Courier, monospace',
            theme: {
                background: '#000000',
                foreground: '#33ff33',
                cursor: '#33ff33',
                cursorAccent: '#000000',
                selection: 'rgba(51, 255, 51, 0.3)',
                black: '#000000',
                red: '#ff3333',
                green: '#33ff33',
                yellow: '#ffff33',
                blue: '#3333ff',
                magenta: '#ff33ff',
                cyan: '#33ffff',
                white: '#ffffff',
                brightBlack: '#666666',
                brightRed: '#ff6666',
                brightGreen: '#66ff66',
                brightYellow: '#ffff66',
                brightBlue: '#6666ff',
                brightMagenta: '#ff66ff',
                brightCyan: '#66ffff',
                brightWhite: '#ffffff'
            },
            cols: 80,
            rows: 24,
            scrollback: 1000
        });

        this.fitAddon = new FitAddon.FitAddon();
        this.terminal.loadAddon(this.fitAddon);

        const terminalEl = document.getElementById('terminal');
        this.terminal.open(terminalEl);
        this.fitAddon.fit();

        window.addEventListener('resize', () => {
            if (this.fitAddon) {
                this.fitAddon.fit();
            }
        });

        this.terminal.onData(data => {
            this.handleTerminalInput(data);
        });

        this.terminal.writeln('\x1b[1;32m╔════════════════════════════════════════════════════════════════════════════╗\x1b[0m');
        this.terminal.writeln('\x1b[1;32m║                          MDL ZORK - WASM EDITION                          ║\x1b[0m');
        this.terminal.writeln('\x1b[1;32m╚════════════════════════════════════════════════════════════════════════════╝\x1b[0m');
        this.terminal.writeln('');
        this.terminal.writeln('\x1b[33mInitializing WebAssembly module...\x1b[0m');
    }

    setupEventListeners() {
        this.startBtn.addEventListener('click', () => this.startGame());
        this.saveBtn.addEventListener('click', () => this.saveGame());
        this.loadBtn.addEventListener('click', () => this.loadGame());
        this.exportBtn.addEventListener('click', () => this.exportSave());
        this.importBtn.addEventListener('click', () => this.importSave());
    }

    // Initialize IndexedDB for persistent storage
    async initIndexedDB() {
        try {
            this.db = await new Promise((resolve, reject) => {
                const request = indexedDB.open('ZorkSaveDB', 1);
                request.onerror = () => reject(request.error);
                request.onsuccess = () => resolve(request.result);
                request.onupgradeneeded = (event) => {
                    const db = event.target.result;
                    if (!db.objectStoreNames.contains('saves')) {
                        db.createObjectStore('saves', { keyPath: 'id' });
                    }
                };
            });
            console.log('IndexedDB initialized');
        } catch (e) {
            console.error('IndexedDB failed to open:', e);
            this.terminal.writeln('\x1b[33m[Warning: Save/load features unavailable]\x1b[0m');
        }
    }

    // Helper: run an IndexedDB transaction as a Promise
    _idbTransaction(storeName, mode, callback) {
        return new Promise((resolve, reject) => {
            const tx = this.db.transaction([storeName], mode);
            const store = tx.objectStore(storeName);
            const result = callback(store);
            tx.oncomplete = () => resolve(result);
            tx.onerror = () => reject(tx.error);
        });
    }

    // Helper: get all records from a store as a Promise
    _idbGetAll(storeName) {
        return new Promise((resolve, reject) => {
            const tx = this.db.transaction([storeName], 'readonly');
            const store = tx.objectStore(storeName);
            const request = store.getAll();
            request.onsuccess = () => resolve(request.result);
            request.onerror = () => reject(request.error);
        });
    }

    updateStatus(message, type = 'info') {
        this.statusEl.textContent = message;
        this.statusEl.className = type;
    }

    handleTerminalInput(data) {
        const code = data.charCodeAt(0);

        // Ctrl+C
        if (code === 3) {
            this.terminal.write('^C\r\n');
            this.inputBuffer = '';
            if (this.isRunning) {
                this.stopGame();
            }
            return;
        }

        // Enter
        if (code === 13 || data === '\r') {
            this.terminal.write('\r\n');
            const command = this.inputBuffer.trim();

            if (command) {
                this.commandHistory.push(command);
                this.historyIndex = this.commandHistory.length;

                if (this.isRunning && this.module) {
                    this.sendToStdin(command + '\n');
                } else {
                    this.terminal.writeln('\x1b[33m[Game not running. Click "Start Game" first.]\x1b[0m');
                }
            }

            this.inputBuffer = '';
            return;
        }

        // Backspace
        if (code === 127 || code === 8) {
            if (this.inputBuffer.length > 0) {
                this.inputBuffer = this.inputBuffer.slice(0, -1);
                this.terminal.write('\b \b');
            }
            return;
        }

        // Up arrow
        if (data === '\x1b[A') {
            if (this.historyIndex > 0) {
                for (let i = 0; i < this.inputBuffer.length; i++) {
                    this.terminal.write('\b \b');
                }
                this.historyIndex--;
                this.inputBuffer = this.commandHistory[this.historyIndex];
                this.terminal.write(this.inputBuffer);
            }
            return;
        }

        // Down arrow
        if (data === '\x1b[B') {
            if (this.historyIndex < this.commandHistory.length) {
                for (let i = 0; i < this.inputBuffer.length; i++) {
                    this.terminal.write('\b \b');
                }
                this.historyIndex++;
                if (this.historyIndex < this.commandHistory.length) {
                    this.inputBuffer = this.commandHistory[this.historyIndex];
                } else {
                    this.inputBuffer = '';
                }
                this.terminal.write(this.inputBuffer);
            }
            return;
        }

        // Ignore other escape sequences
        if (code === 27) return;

        // Regular character
        if (code >= 32 && code <= 126) {
            this.inputBuffer += data;
            this.terminal.write(data);
        }
    }

    sendToStdin(text) {
        if (!this.module) return;
        for (let i = 0; i < text.length; i++) {
            this.module.stdinBuffer.push(text.charCodeAt(i));
        }
        // If the interpreter is suspended waiting for input, wake it up
        if (this.module.stdinResolve) {
            const resolve = this.module.stdinResolve;
            this.module.stdinResolve = null;
            resolve(this.module.stdinBuffer.shift());
        }
    }

    async loadWASM() {
        this.updateStatus('Loading WASM module...', 'loading');
        this.terminal.writeln('\x1b[33mLoading MDL interpreter...\x1b[0m');

        try {
            const moduleConfig = {
                preRun: [function(module) {
                    var self = this;

                    // Set up the async stdin buffer used by EM_ASYNC_JS
                    // in wasm_input.h (wasm_stdin_getchar reads from these)
                    module.stdinBuffer = [];
                    module.stdinResolve = null;

                    // FS.init for stdout/stderr only; stdin is handled
                    // entirely by wasm_stdin_getchar via EM_ASYNC_JS
                    module.FS.init(
                        function() { return null; },
                        function(val) {
                            if (val !== null && val !== undefined) {
                                if (val === 10) {
                                    self.terminal.write('\r\n');
                                } else {
                                    self.terminal.write(String.fromCharCode(val));
                                }
                            }
                        },
                        function(val) {
                            if (val !== null && val !== undefined) {
                                self.terminal.write('\x1b[31m' + String.fromCharCode(val) + '\x1b[0m');
                            }
                        }
                    );
                }.bind(this)],

                onRuntimeInitialized: () => {
                    console.log('WASM runtime initialized');
                }
            };

            this.module = await createMDLI(moduleConfig);

            this.isReady = true;
            this.updateStatus('Ready to start game', 'ready');
            this.startBtn.disabled = false;
            this.versionSelect.disabled = false;

            this.terminal.writeln('\x1b[32mModule loaded successfully.\x1b[0m');
            this.terminal.writeln('');
            this.terminal.writeln('\x1b[36mSelect a game version and click "Start Game" to begin.\x1b[0m');
            this.terminal.writeln('');

        } catch (error) {
            this.updateStatus('Failed to load WASM module', 'error');
            this.terminal.writeln('\x1b[31mFATAL ERROR: ' + error.message + '\x1b[0m');
            console.error('WASM load error:', error);
        }
    }

    async startGame() {
        if (!this.isReady || this.isRunning) return;

        const version = this.versionSelect.value;
        const gameInfo = this.gameVersions[version];
        if (!gameInfo) {
            this.terminal.writeln('\x1b[31mError: Unknown game version\x1b[0m');
            return;
        }

        this.updateStatus(`Starting ${gameInfo.name}...`, 'loading');
        this.currentGamePath = gameInfo.path;

        // Set up UI state
        this.terminal.clear();
        this.terminal.writeln('\x1b[1;32m═══════════════════════════════════════════════════════════════════════════\x1b[0m');
        this.terminal.writeln(`\x1b[1;33m  ${gameInfo.name.toUpperCase()}\x1b[0m`);
        this.terminal.writeln('\x1b[1;32m═══════════════════════════════════════════════════════════════════════════\x1b[0m');
        this.terminal.writeln('');

        this.startBtn.disabled = true;
        this.versionSelect.disabled = true;
        this.isRunning = true;
        this.saveBtn.disabled = false;
        this.loadBtn.disabled = false;
        this.exportBtn.disabled = false;
        this.importBtn.disabled = false;

        // Change to game directory
        try {
            this.module.FS.chdir(gameInfo.path);
        } catch (e) {
            this.terminal.writeln('\x1b[31mError: Could not find game directory: ' + e.message + '\x1b[0m');
            this.stopGame();
            return;
        }

        // Verify save file exists
        const saveFilePath = `${gameInfo.path}/${gameInfo.saveFile}`;
        try {
            this.module.FS.stat(saveFilePath);
        } catch (e) {
            this.terminal.writeln('\x1b[31mError: Save file not found: ' + saveFilePath + '\x1b[0m');
            this.stopGame();
            return;
        }

        this.updateStatus('Game running', 'ready');
        this.terminal.writeln('\x1b[36mStarting MDL interpreter...\x1b[0m');
        this.terminal.writeln('');

        // Call the WASM game starter (async: Asyncify suspends C code on stdin reads)
        try {
            if (!this.module._mdl_start_game) {
                throw new Error('mdl_start_game not available in WASM module');
            }

            const result = await this.module.ccall(
                'mdl_start_game', 'number',
                ['string', 'string'], [gameInfo.path, gameInfo.saveFile],
                {async: true}
            );

            if (result !== 0) {
                let errorMsg = 'Unknown error';
                if (this.module._mdl_get_last_error) {
                    errorMsg = this.module.ccall('mdl_get_last_error', 'string', [], []);
                }
                this.terminal.writeln(`\x1b[31mError starting game: ${errorMsg}\x1b[0m`);
            }
            this.stopGame();
        } catch (mainError) {
            const errorMsg = mainError.message || mainError.toString();
            if (!errorMsg.includes('exit(0)')) {
                console.error('Game error:', mainError);
                this.terminal.writeln('\x1b[31mError: ' + errorMsg + '\x1b[0m');
            }
            this.stopGame();
        }
    }

    // Save game state to IndexedDB
    async saveGame() {
        if (!this.isRunning || !this.db) {
            this.terminal.writeln('\x1b[33m[Cannot save - game not running or storage unavailable]\x1b[0m');
            return;
        }

        try {
            const version = this.versionSelect.value;
            const timestamp = new Date().toISOString();

            const saveData = {
                id: `${version}_${Date.now()}`,
                version: version,
                timestamp: timestamp,
                // TODO: Capture actual WASM filesystem state for full save/restore
                fs: this.captureFilesystem()
            };

            await this._idbTransaction('saves', 'readwrite', (store) => {
                store.put(saveData);
            });

            this.terminal.writeln(`\x1b[32mGame saved: ${timestamp}\x1b[0m`);
        } catch (e) {
            this.terminal.writeln(`\x1b[31mSave error: ${e.message}\x1b[0m`);
        }
    }

    // Load game state from IndexedDB
    async loadGame() {
        if (!this.db) {
            this.terminal.writeln('\x1b[33m[Storage unavailable]\x1b[0m');
            return;
        }

        try {
            const version = this.versionSelect.value;
            const allSaves = await this._idbGetAll('saves');
            const saves = allSaves
                .filter(s => s.version === version)
                .sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp));

            if (saves.length === 0) {
                this.terminal.writeln('\x1b[33m[No saved games found for this version]\x1b[0m');
                return;
            }

            const saveData = saves[0];
            this.restoreFilesystem(saveData.fs);
            this.terminal.writeln(`\x1b[32mGame loaded: ${saveData.timestamp}\x1b[0m`);
        } catch (e) {
            this.terminal.writeln(`\x1b[31mLoad error: ${e.message}\x1b[0m`);
        }
    }

    // Export save to file
    async exportSave() {
        if (!this.db) {
            this.terminal.writeln('\x1b[33m[Storage unavailable]\x1b[0m');
            return;
        }

        try {
            const version = this.versionSelect.value;
            const allSaves = await this._idbGetAll('saves');
            const saves = allSaves
                .filter(s => s.version === version)
                .sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp));

            if (saves.length === 0) {
                this.terminal.writeln('\x1b[33m[No saved games to export]\x1b[0m');
                return;
            }

            const saveData = saves[0];
            const blob = new Blob([JSON.stringify(saveData, null, 2)], { type: 'application/json' });
            const url = URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.href = url;
            a.download = `zork_${version}_${saveData.timestamp.replace(/[:.]/g, '-')}.json`;
            a.click();
            URL.revokeObjectURL(url);

            this.terminal.writeln('\x1b[32mSave exported\x1b[0m');
        } catch (e) {
            this.terminal.writeln(`\x1b[31mExport error: ${e.message}\x1b[0m`);
        }
    }

    // Import save from file
    async importSave() {
        if (!this.db) {
            this.terminal.writeln('\x1b[33m[Storage unavailable]\x1b[0m');
            return;
        }

        const input = document.createElement('input');
        input.type = 'file';
        input.accept = '.json';

        input.onchange = async (e) => {
            const file = e.target.files[0];
            if (!file) return;

            try {
                const text = await file.text();
                const saveData = JSON.parse(text);

                if (!saveData.id || !saveData.version || !saveData.timestamp) {
                    this.terminal.writeln('\x1b[31mInvalid save file format\x1b[0m');
                    return;
                }

                saveData.id = `${saveData.version}_${Date.now()}_imported`;

                await this._idbTransaction('saves', 'readwrite', (store) => {
                    store.put(saveData);
                });

                this.terminal.writeln(`\x1b[32mSave imported: ${saveData.timestamp}\x1b[0m`);
            } catch (e) {
                this.terminal.writeln(`\x1b[31mImport error: ${e.message}\x1b[0m`);
            }
        };

        input.click();
    }

    // TODO: Implement full WASM filesystem state capture for save/restore
    captureFilesystem() {
        if (!this.module || !this.module.FS) return null;
        try {
            return {
                cwd: this.module.FS.cwd(),
                timestamp: Date.now()
            };
        } catch (e) {
            console.error('Filesystem capture error:', e);
            return null;
        }
    }

    // TODO: Implement full WASM filesystem state restore from saved data
    restoreFilesystem(fsData) {
        if (!this.module || !this.module.FS || !fsData) return;
        try {
            if (fsData.cwd) {
                this.module.FS.chdir(fsData.cwd);
            }
        } catch (e) {
            console.error('Filesystem restore error:', e);
        }
    }

    stopGame() {
        this.isRunning = false;
        this.startBtn.disabled = false;
        this.versionSelect.disabled = false;
        this.saveBtn.disabled = true;
        this.loadBtn.disabled = true;
        this.exportBtn.disabled = true;
        this.importBtn.disabled = true;

        this.updateStatus('Game stopped', 'ready');
        this.terminal.writeln('');
        this.terminal.writeln('\x1b[33m[Game ended. Select a version to play again.]\x1b[0m');
    }
}

// Initialize when page loads
let game;

document.addEventListener('DOMContentLoaded', () => {
    game = new ZorkGame();
    game.loadWASM();
});
