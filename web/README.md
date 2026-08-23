# MDL Zork - Web Application

This directory contains the static web application for MDL Zork, compiled to WebAssembly.

## Quick Start

1. **Build the WASM files** (if not already built):
   ```bash
   cd ..
   make wasm-build
   ```

2. **Start local server**:
   ```bash
   python3 -m http.server 8000
   ```

3. **Open in browser**:
   ```
   http://localhost:8000/web/
   ```

4. **Hard refresh** to clear cache:
   - Mac: `Cmd + Shift + R`
   - Windows/Linux: `Ctrl + Shift + R`

## Files

- `index.html` - Main application page
- `app.js` - Game interface and WASM integration
- `style.css` - Terminal styling
- `manifest.json` - PWA manifest
- `sw.js` - Service worker for offline support
- `icon.svg` - App icon (SVG)
- `icons/` - Generated PNG icons for PWA
- `mdli.js` - Emscripten JavaScript glue code (generated)
- `mdli.wasm` - WebAssembly binary (generated)
- `mdli.data` - Preloaded game files (generated)

## Current Status

**✅ Working:**
- WASM compilation and loading
- File system with embedded game data
- Save file loading
- Game initialization and display
- Terminal emulation with xterm.js
- PWA manifest and icons

**⚠️ Known Limitation:**
- Interactive gameplay requires modifying the MDL interpreter C source code
- The game successfully loads and displays the starting location
- User input triggers EOF due to blocking I/O in the interpreter

See `../WASM_STATUS.md` for technical details and solutions.

## What You'll See

When you load the game:
```
Welcome to 'Confusion', a MDL interpreter.
...
West of House
This is an open field west of a white house, with a boarded front door.
There is a small mailbox here.
A rubber mat saying 'Welcome to Zork!' lies by the door.

[Limitation message explaining the stdin issue]
```

This demonstrates that ~90% of the WASM migration is complete. The remaining work requires modifying the C code to use non-blocking I/O.

## Development

To rebuild after changes:
```bash
cd ..
make clean-wasm && make wasm-build
```

Files are automatically copied to this directory by the build system.

## Deployment

For GitHub Pages deployment, these files can be served as-is. The application is fully static with no server dependencies.
