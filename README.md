# MDL Zork: Original Mainframe Zork Collection

[![CI](https://github.com/jordanhubbard/mdlzork/actions/workflows/ci.yml/badge.svg)](https://github.com/jordanhubbard/mdlzork/actions/workflows/ci.yml)

Play the original mainframe Zork games written in MDL (MIT Design Language) from 1977-1981. The four playable versions run either in a native terminal or entirely in a browser through WebAssembly.

**Play online:** https://jordanhubbard.github.io/mdlzork

## Features

- **Browser and terminal play** - Use the WebAssembly PWA or native Confusion interpreter
- **Four playable versions** - Explore Zork snapshots from 1977 through 1981
- **Portable save files** - Transfer native Confusion `.SAVE` files between the browser sandbox and host
- **Offline support** - The PWA caches its application shell, interpreter, and game data
- **Responsive terminal** - xterm.js interface for desktop and mobile browsers

## Quick Start

### Play Online (Easiest)

Visit **https://jordanhubbard.github.io/mdlzork** to play without installing local build tools.

### Build and Run Locally

```bash
git clone --recurse-submodules https://github.com/jordanhubbard/mdlzork.git
cd mdlzork
make run
```

Then open `http://localhost:8000/`. If the repository was cloned without submodules, initialize them first with `git submodule update --init --recursive`.

### Native Terminal Build (Advanced)

For running in a native terminal (no browser):

```bash
make build-native
make run-native GAME=mdlzork_810722
```

To start from another image, pass `SAVE`, for example `make run-native GAME=mdlzork_810722 SAVE=MTRZORK/ZORK.SAVE`.

## Game Versions

### MDL Zork 1977-12-12
The earliest known version. A 500-point game fully playable to completion. Reconstructed with files from later versions to fill in missing pieces (notably the "melee" file). No end-game - you win when you reach 500 points.

### MDL Zork 1978-01-24
Enhanced version with parser improvements and an added end-game. The end-game is incomplete - the final puzzle with the dungeon master cannot be solved.

### MDL Zork 1979-12-11
A 616-point version with a 100-point end-game that is nearly identical to the 1981 version.

### MDL Zork 1981-07-22
The definitive mainframe Zork. Almost identical to the 1979 version with three small bugfixes and another issue of the US NEWS & DUNGEON REPORT. This is Bob Supnik's 2003 release, the basis for many later versions, patched by Matthew Russotto to work in Confusion.

### Dungeon 3.2b
Fortran version by Bob Supnik that closely follows the 1981 MDL version.

### Zork 285
ZIL version of the very first Zork from June 14, 1977.

### PDP-10 ITS Binaries
Recovered binary files that work with MDL in the [PDP-10 ITS emulator](https://github.com/PDP-10/its).

## Build System

### WASM Build (Progressive Web App)

```bash
make build          # Build the browser application
make run            # Build and serve on localhost:8000
make wasm-deps      # Install the pinned Emscripten SDK
make clean-wasm     # Clean WASM artifacts
```

**Requirements:**
- Git and initialized submodules
- Python 3 (for local test server only)
- Make
- Enough disk space for Emscripten and generated game data

**Output:**
- `build/web/mdli.js` - Emscripten glue code
- `build/web/mdli.wasm` - Compiled interpreter
- `build/web/mdli.data` - Preloaded game data

### Native Build (Terminal Application)

```bash
make build-native
make run-native GAME=mdlzork_810722
make run-native GAME=mdlzork_810722 SAVE=MTRZORK/ZORK.SAVE
make validate            # Load-test all four game images
```

**Requirements:**
- C++ compiler (gcc/clang)
- Boehm GC library (`make install-deps` can install it)

**Output:** `confusion-mdl/mdli` executable

## Playing the Games

### In Browser (Recommended)

1. Visit https://jordanhubbard.github.io/mdlzork/ or run `make run` locally.
2. Select a game version.
3. Click **Start Game**.
4. Type commands in the terminal.

**Game Controls:**
- Type commands and press Enter
- Up/Down arrows for command history
- Use **Restart** after a game ends to create a fresh interpreter instance
- Type `SAVE`, then use **Download Save File** to copy it out of the browser sandbox
- Use **Upload Save File** for the matching game version, then type `RESTORE`

Browser save files are not stored automatically. The game first writes a native Confusion save into its in-memory filesystem; the download and upload controls transfer that file across the browser sandbox boundary. Save files are version-specific.

### Terminal (Native CLI)

```bash
make run-native GAME=mdlzork_810722
```

## Manual MDL Usage

If you want to work with the raw MDL files:

```bash
cd mdlzork_810722
../confusion-mdl/mdli
```

Then in the MDL interpreter:
```lisp
<FLOAD "run.mud">     ; Load and compile game from source
```

Or to restore a save file:
```lisp
<RESTORE "<SAVEFILE>ZORK.SAVE">
```

To start directly from a save file:
```bash
../confusion-mdl/mdli -r MDL/MADADV.SAVE
```

## Project Structure

```
mdlzork/
├── .github/workflows/    # CI/CD for auto-deployment
│   └── ci.yml            # Build validation + GitHub Pages deployment
├── web/                  # Progressive Web App
│   ├── index.html        # Main UI
│   ├── app.js            # Game logic + WASM integration
│   ├── style.css         # Retro terminal styling
│   ├── sw.js             # Service Worker (offline support)
│   ├── manifest.json     # PWA manifest
│   ├── icon.svg          # App icon
│   └── offline.html      # Offline fallback page
├── confusion-mdl/        # MDL interpreter (submodule)
│   ├── Makefile          # Native build
│   ├── Makefile.wasm     # WASM build
│   ├── gc_stub.h/cpp     # GC replacement for WASM
│   └── wasm_config.h     # WASM configuration
├── scripts/              # Build support and WASM smoke test
├── build/                # Generated WASM and assembled web output
├── emsdk/                # Pinned Emscripten SDK (generated locally)
├── mdlzork_771212/       # Zork 1977-12-12 (500 points)
├── mdlzork_780124/       # Zork 1978-01-24 (with end-game)
├── mdlzork_791211/       # Zork 1979-12-11 (616 points)
├── mdlzork_810722/       # Zork 1981-07-22 (final MDL)
├── dungeon_3_2b/         # Fortran version
├── zork_285/             # ZIL version (June 1977)
└── Makefile              # Build system
```

## Architecture

### WASM Build Pipeline
1. **C/C++ source** (`confusion-mdl/`) is compiled into a modularized WebAssembly interpreter.
2. **Memory management** uses the interpreter's WASM allocation shim instead of Boehm GC.
3. **Game files** for all four playable versions are preloaded into Emscripten's virtual filesystem.
4. **Web application** connects xterm.js to asynchronous interpreter input and output.
5. **Save transfer** exposes native game save files as browser downloads and uploads.

### Deployment
- GitHub Actions builds on pushes and pull requests.
- Native CI builds on Linux and macOS and load-tests all four game images.
- WASM CI uses Emscripten 4.0.20 and smoke-tests the module and preloaded files.
- A headless-browser test starts Zork, enters `look`, and rejects unexpected EOF failures.
- GitHub Pages serves the assembled static application from `build/web/`.
- The service worker caches the application and game payload for offline use.

## Documentation

- **web/README.md** - Browser application details
- **Individual game directories** - Game-specific READMEs

## Troubleshooting

### Build Issues

**Emscripten setup fails**
```bash
make wasm-deps
```

**Submodule is missing or at the wrong revision**
```bash
git submodule update --init --recursive
```

**Native build: "libgc not found"**
```bash
# macOS
brew install bdw-gc

# Linux
sudo apt-get install libgc-dev
```

### Runtime Issues

**PWA won't install**
- Must be served over HTTPS (GitHub Pages) or localhost
- Check browser console for manifest errors

**Service Worker not registering**
- Clear site data and reload
- Check browser supports Service Workers

**Save-file transfer not working**
- Type `SAVE` before downloading so the browser sandbox contains current progress
- Select the matching game version before uploading a compatible `.SAVE` file
- Type `RESTORE` after the upload completes

## Make Targets Reference

### Main Targets
- `make` - Default: build and serve the WASM application
- `make build` - Build WASM version
- `make run` - Build WASM and start test server
- `make help` - Show all available targets

### Native Targets
- `make build-native` - Build native interpreter
- `make run-native GAME=<directory>` - Run a game using its default image
- `make run-native GAME=<directory> SAVE=<path>` - Run a selected image
- `make validate` - Load-test the four playable game images

### WASM Targets
- `make wasm-deps` - Install Emscripten SDK
- `make wasm-build` - Build WASM version
- `make wasm-serve` - Serve WASM build
- `make clean-wasm` - Clean WASM artifacts

### Release Targets
- `make package` - Package both releases
- `make package-native` - Package native release
- `make package-wasm` - Package WASM release
- `make clean-releases` - Clean release artifacts

### Cleanup
- `make clean` - Clean generated build artifacts
- `make clean-all` - Clean everything

## Credits

**Original Zork Authors:**
- Tim Anderson
- Marc Blank
- Bruce Daniels
- Dave Lebling

**MDL Interpreter:**
- Matthew Russotto - [Confusion](http://www.russotto.net/git/mrussotto/confusion)
- Original at [IF-Archive](http://www.ifarchive.org/indexes/if-archive/programming/mdl/interpreters/confusion/)
- Benjamin Slade's [patched version](https://gitlab.com/emacsomancer/confusion-mdl)

**Additional Resources:**
- Benjamin Slade's [blog post](https://babbagefiles.xyz/zork-confusion/) on compiling Confusion
- Jeff Claar's [C++ adaptation](https://bitbucket.org/jclaar3/zork/src/master/) (carefully made from 810722 MDL source)

## License

See individual game directories for licensing information. The MDL interpreter (Confusion) and game sources have their own respective licenses.
