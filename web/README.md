# MDL Zork Web Application

This directory contains the source assets for the WebAssembly Progressive Web App. Generated interpreter files are assembled with these assets in `build/web/`.

## Run Locally

From the repository root:

```bash
make run
```

Open `http://localhost:8000/`. The build pins Emscripten and preloads all four playable game versions.

## Save Files

The games write native Confusion save files inside Emscripten's in-memory filesystem:

1. Type `SAVE` in the game.
2. Click **Download Save File** to export the resulting `.SAVE` file to the host.
3. In a later session, click **Upload Save File** and select that file.
4. Type `RESTORE` in the game.

Save files are version-specific. Upload a save into the same game version that created it.

## Source Files

- `index.html` - Application shell
- `app.js` - Terminal and WebAssembly integration
- `style.css` - Responsive terminal styling
- `manifest.json` - Install metadata
- `sw.js` - Offline cache and update lifecycle
- `offline.html` - Navigation fallback
- `icon.svg` and `icons/` - Application icons

`mdli.js`, `mdli.wasm`, and `mdli.data` are generated under `build/` and are not source files.
