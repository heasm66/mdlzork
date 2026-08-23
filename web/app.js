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
        this.exportBtn = document.getElementById('export-btn');
        this.importBtn = document.getElementById('import-btn');
        this.saveFileInput = document.getElementById('save-file-input');

        this.isReady = false;
        this.isRunning = false;
        this.hasRun = false;
        this.inputBuffer = '';
        this.commandHistory = [];
        this.historyIndex = -1;
        this.currentGamePath = null;

        // Game version mappings
        this.gameVersions = {
            'zork-810722': {
                name: 'Zork 1981-07-22 (Final MDL, 585 pts)',
                path: '/game/mdlzork_810722',
                saveFile: 'MDL/MADADV.SAVE',
                userSaveFile: 'MTRZORK/ZORK.SAVE',
                description: 'The final MDL version of Zork, split into three parts for Infocom.',
                maxPoints: 585
            },
            'zork-791211': {
                name: 'Zork 1979-12-11 (616 pts)',
                path: '/game/mdlzork_791211',
                saveFile: 'MDL/MADADV.SAVE',
                userSaveFile: 'MTRZORK/ZORK.SAVE',
                description: 'The most complete single-file Zork with all puzzles and end-game.',
                maxPoints: 616
            },
            'zork-780124': {
                name: 'Zork 1978-01-24 (Incomplete end-game)',
                path: '/game/mdlzork_780124',
                saveFile: 'MDL/MADADV.SAVE',
                userSaveFile: 'SAVEFILE/ZORK.SAVE',
                description: 'Early version with partial end-game implementation.',
                maxPoints: null
            },
            'zork-771212': {
                name: 'Zork 1977-12-12 (500 pts, no end-game)',
                path: '/game/mdlzork_771212',
                saveFile: 'MDL/MADADV.SAVE',
                userSaveFile: 'SAVEFILE/ZORK.SAVE',
                description: 'The earliest surviving playable version of Zork.',
                maxPoints: 500
            }
        };

        this.setupTerminal();
        this.setupEventListeners();
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
            scrollback: 1000,
            screenReaderMode: true
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
        this.startBtn.addEventListener('click', () => {
            if (this.hasRun) {
                window.location.reload();
            } else {
                this.startGame();
            }
        });
        this.exportBtn.addEventListener('click', () => this.exportSaveFile());
        this.importBtn.addEventListener('click', () => this.saveFileInput.click());
        this.saveFileInput.addEventListener('change', (event) => this.importSaveFile(event));
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
                this.terminal.writeln('\x1b[33m[Use Restart to reset the interpreter safely.]\x1b[0m');
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
            }

            if (this.isRunning && this.module) {
                this.sendToStdin(this.inputBuffer + '\n');
            } else {
                this.terminal.writeln('\x1b[33m[Game not running. Click "Start Game" first.]\x1b[0m');
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
            this.exportBtn.disabled = false;
            this.importBtn.disabled = false;

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
        if (!this.isReady || this.isRunning || this.hasRun) return;

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
        this.hasRun = true;
        this.exportBtn.disabled = false;
        this.importBtn.disabled = false;

        // Change to game directory
        try {
            this.module.FS.chdir(gameInfo.path);
        } catch (e) {
            this.terminal.writeln('\x1b[31mError: Could not find game directory: ' + e.message + '\x1b[0m');
            this.finishGame();
            return;
        }

        // Verify save file exists
        const saveFilePath = `${gameInfo.path}/${gameInfo.saveFile}`;
        try {
            this.module.FS.stat(saveFilePath);
        } catch (e) {
            this.terminal.writeln('\x1b[31mError: Save file not found: ' + saveFilePath + '\x1b[0m');
            this.finishGame();
            return;
        }

        this.updateStatus('Game running', 'ready');
        this.terminal.writeln('\x1b[36mStarting MDL interpreter...\x1b[0m');
        this.terminal.writeln('');

        // Call the WASM game starter (async: Asyncify suspends C code on stdin reads)
        try {
            const result = await this.module.ccall(
                'mdl_start_game', 'number',
                ['string', 'string'], [gameInfo.path, gameInfo.saveFile],
                {async: true}
            );

            if (result !== 0) {
                let errorMsg = 'Unknown error';
                errorMsg = this.module.ccall('mdl_get_last_error', 'string', [], []);
                this.terminal.writeln(`\x1b[31mError starting game: ${errorMsg}\x1b[0m`);
            }
            this.finishGame();
        } catch (mainError) {
            const errorMsg = mainError.message || mainError.toString();
            if (!errorMsg.includes('exit(0)')) {
                console.error('Game error:', mainError);
                this.terminal.writeln('\x1b[31mError: ' + errorMsg + '\x1b[0m');
            }
            this.finishGame();
        }
    }

    getUserSavePath() {
        const gameInfo = this.gameVersions[this.versionSelect.value];
        return `${gameInfo.path}/${gameInfo.userSaveFile}`;
    }

    exportSaveFile() {
        try {
            const data = this.module.FS.readFile(this.getUserSavePath());
            const blob = new Blob([data], { type: 'application/octet-stream' });
            const url = URL.createObjectURL(blob);
            const link = document.createElement('a');
            link.href = url;
            link.download = `${this.versionSelect.value}-${new Date().toISOString().replace(/[:.]/g, '-')}.SAVE`;
            document.body.appendChild(link);
            link.click();
            link.remove();
            setTimeout(() => URL.revokeObjectURL(url), 0);
            this.terminal.writeln('\x1b[32m[Save file downloaded. Type SAVE in the game first to capture current progress.]\x1b[0m');
        } catch (error) {
            this.terminal.writeln(`\x1b[31m[Could not download save file: ${error.message}]\x1b[0m`);
        }
    }

    async importSaveFile(event) {
        const file = event.target.files[0];
        event.target.value = '';
        if (!file) return;

        if (file.size < 100 || file.size > 16 * 1024 * 1024) {
            this.terminal.writeln('\x1b[31m[Invalid save file size.]\x1b[0m');
            return;
        }

        try {
            const data = new Uint8Array(await file.arrayBuffer());
            this.module.FS.writeFile(this.getUserSavePath(), data);
            this.terminal.writeln('\x1b[32m[Save file uploaded. Type RESTORE in the game to load it.]\x1b[0m');
        } catch (error) {
            this.terminal.writeln(`\x1b[31m[Could not upload save file: ${error.message}]\x1b[0m`);
        }
    }

    finishGame() {
        this.isRunning = false;
        this.startBtn.disabled = false;
        this.startBtn.textContent = 'Restart';
        this.importBtn.disabled = true;

        this.updateStatus('Game ended', 'ready');
        this.terminal.writeln('');
        this.terminal.writeln('\x1b[33m[Game ended. Restart to create a fresh interpreter.]\x1b[0m');
    }
}

// Initialize when page loads
let game;

document.addEventListener('DOMContentLoaded', () => {
    game = new ZorkGame();
    game.loadWASM();
});
