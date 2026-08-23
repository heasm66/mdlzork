# Top-level Makefile for MDL Zork Web Launcher
.PHONY: all clean clean-all interpreter run build run-native build-native wasm-deps wasm-build wasm-serve package package-native package-wasm clean-releases clean-wasm validate help check-submodules check-deps install-deps

.DEFAULT_GOAL := run

# Local test server port
SERVER_PORT := 8000
EMSDK_VERSION := 4.0.20

# Interpreter paths
CONFUSION_DIR := confusion-mdl
CONFUSION_INTERPRETER := $(CONFUSION_DIR)/mdli

# ============================================================================
# Submodule Management
# ============================================================================

# Check if submodules are initialized, initialize if necessary
check-submodules:
	@if [ ! -f "$(CONFUSION_DIR)/Makefile" ]; then \
		echo "Submodules are not initialized; run 'git submodule update --init --recursive'"; \
		exit 1; \
	fi
	@EXPECTED=$$(git ls-files --stage $(CONFUSION_DIR) | cut -d' ' -f2); \
	ACTUAL=$$(git -C $(CONFUSION_DIR) rev-parse HEAD); \
	if [ "$$EXPECTED" != "$$ACTUAL" ]; then \
		echo "$(CONFUSION_DIR) is at $$ACTUAL, expected $$EXPECTED"; \
		echo "Run 'git submodule update --init --recursive'"; \
		exit 1; \
	fi

# Check if required dependencies are installed
check-deps:
	@echo "Checking build dependencies..."
	@MISSING_DEPS=0; \
	if ! command -v gcc >/dev/null 2>&1 && ! command -v clang >/dev/null 2>&1; then \
		echo "❌ C compiler not found (gcc or clang required)"; \
		MISSING_DEPS=1; \
	fi; \
	if ! command -v make >/dev/null 2>&1; then \
		echo "❌ make not found"; \
		MISSING_DEPS=1; \
	fi; \
	GC_FOUND=0; \
	if command -v pkg-config >/dev/null 2>&1; then \
		if pkg-config --exists bdw-gc 2>/dev/null || pkg-config --exists gc 2>/dev/null; then \
			GC_FOUND=1; \
		fi; \
	fi; \
	if [ $$GC_FOUND -eq 0 ]; then \
		if [ "$$(uname)" = "Darwin" ]; then \
			if [ -f /opt/homebrew/lib/libgc.dylib ] || [ -f /usr/local/lib/libgc.dylib ]; then \
				GC_FOUND=1; \
			fi; \
		elif [ "$$(uname)" = "Linux" ]; then \
			if [ -f /usr/include/gc/gc.h ] || [ -f /usr/local/include/gc/gc.h ]; then \
				GC_FOUND=1; \
			fi; \
		fi; \
	fi; \
	if [ $$GC_FOUND -eq 0 ]; then \
		echo "❌ Boehm GC library (bdw-gc) not found"; \
		MISSING_DEPS=1; \
	fi; \
	if [ $$MISSING_DEPS -eq 1 ]; then \
		echo ""; \
		echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"; \
		echo "Missing dependencies detected!"; \
		echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"; \
		echo ""; \
		echo "Quick install:"; \
		echo "  make install-deps"; \
		echo ""; \
		echo "Or install manually:"; \
		echo ""; \
		if [ "$$(uname)" = "Darwin" ]; then \
			echo "macOS (Homebrew):"; \
			echo "  brew install bdw-gc"; \
		elif [ "$$(uname)" = "Linux" ]; then \
			if command -v apt-get >/dev/null 2>&1; then \
				echo "Debian/Ubuntu:"; \
				echo "  sudo apt-get update"; \
				echo "  sudo apt-get install build-essential libgc-dev"; \
			elif command -v yum >/dev/null 2>&1; then \
				echo "RedHat/CentOS:"; \
				echo "  sudo yum groupinstall 'Development Tools'"; \
				echo "  sudo yum install gc-devel"; \
			elif command -v dnf >/dev/null 2>&1; then \
				echo "Fedora:"; \
				echo "  sudo dnf groupinstall 'Development Tools'"; \
				echo "  sudo dnf install gc-devel"; \
			elif command -v pacman >/dev/null 2>&1; then \
				echo "Arch Linux:"; \
				echo "  sudo pacman -S base-devel gc"; \
			else \
				echo "Linux:"; \
				echo "  Install build-essential/gcc, make, and bdw-gc (Boehm GC) for your distribution"; \
			fi; \
		else \
			echo "Please install: gcc/clang, make, and bdw-gc (Boehm GC)"; \
		fi; \
		echo ""; \
		echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"; \
		exit 1; \
	fi
	@echo "✅ All build dependencies found"

# Install required dependencies for the current platform
install-deps:
	@echo "Installing build dependencies..."
	@if [ "$$(uname)" = "Darwin" ]; then \
		echo "macOS detected - using Homebrew"; \
		if ! command -v brew >/dev/null 2>&1; then \
			echo "❌ Homebrew not found. Please install from https://brew.sh"; \
			exit 1; \
		fi; \
		echo "Installing bdw-gc..."; \
		brew install bdw-gc; \
		echo "✅ Dependencies installed successfully"; \
	elif [ "$$(uname)" = "Linux" ]; then \
		if command -v apt-get >/dev/null 2>&1; then \
			echo "Debian/Ubuntu detected - using apt-get"; \
			echo "Installing build-essential and libgc-dev..."; \
			sudo apt-get update && sudo apt-get install -y build-essential libgc-dev pkg-config; \
			echo "✅ Dependencies installed successfully"; \
		elif command -v yum >/dev/null 2>&1; then \
			echo "RedHat/CentOS detected - using yum"; \
			echo "Installing Development Tools and gc-devel..."; \
			sudo yum groupinstall -y 'Development Tools' && sudo yum install -y gc-devel; \
			echo "✅ Dependencies installed successfully"; \
		elif command -v dnf >/dev/null 2>&1; then \
			echo "Fedora detected - using dnf"; \
			echo "Installing Development Tools and gc-devel..."; \
			sudo dnf groupinstall -y 'Development Tools' && sudo dnf install -y gc-devel; \
			echo "✅ Dependencies installed successfully"; \
		elif command -v pacman >/dev/null 2>&1; then \
			echo "Arch Linux detected - using pacman"; \
			echo "Installing base-devel and gc..."; \
			sudo pacman -S --noconfirm base-devel gc; \
			echo "✅ Dependencies installed successfully"; \
		else \
			echo "❌ Unknown Linux distribution"; \
			echo "Please manually install: gcc, make, and bdw-gc (Boehm GC)"; \
			exit 1; \
		fi; \
	else \
		echo "❌ Unsupported operating system: $$(uname)"; \
		echo "Please manually install: gcc/clang, make, and bdw-gc (Boehm GC)"; \
		exit 1; \
	fi

# WASM paths
EMSDK_DIR := emsdk
EMSDK_ACTIVATE := $(EMSDK_DIR)/emsdk_env.sh

# Build directories
BUILD_DIR := build
WASM_BUILD_DIR := $(BUILD_DIR)/wasm
WEB_BUILD_DIR := $(BUILD_DIR)/web

# Default target - build and run WASM
all: run

# ============================================================================
# High-Level Targets (Recommended)
# ============================================================================

# Build browser-ready WASM application
build: wasm-build
	@echo ""
	@echo "✅ WASM build complete!"
	@echo ""
	@echo "Files generated:"
	@echo "  - $(WASM_BUILD_DIR)/mdli.js"
	@echo "  - $(WASM_BUILD_DIR)/mdli.wasm"
	@echo "  - $(WASM_BUILD_DIR)/mdli.data"
	@echo ""
	@echo "Web app assembled in $(WEB_BUILD_DIR)/"
	@echo ""
	@echo "To test: make run"
	@echo "Then open: http://localhost:$(SERVER_PORT)"

# Run application (serve WASM in browser)
run: build
	@echo ""
	@echo "Starting web server for WASM build..."
	@echo "  📡 Server: http://localhost:$(SERVER_PORT)"
	@echo ""
	@echo "Press Ctrl+C to stop server"
	@echo ""
	python3 -m http.server $(SERVER_PORT) -d $(WEB_BUILD_DIR)

# Build native interpreter (CLI use)
build-native: interpreter
	@echo ""
	@echo "✅ Native interpreter built!"
	@echo ""
	@echo "Usage:"
	@echo "  make run-native GAME=mdlzork_810722"
	@echo "  make run-native GAME=mdlzork_810722 SAVE=MDL/MADADV.SAVE"

# Run native CLI version (compiled executable)
# Usage: make run-native GAME=<game-name> [SAVE=<save-file>]
# Example: make run-native GAME=mdlzork_810722
# Example: make run-native GAME=mdlzork_810722 SAVE=MDL/MADADV.SAVE
run-native: interpreter
	@if [ -z "$(GAME)" ]; then \
		echo ""; \
		echo "Usage: make run-native GAME=<game-name> [SAVE=<save-file>]"; \
		echo ""; \
		echo "Available games:"; \
		echo "  - mdlzork_771212  (Zork 1977-12-12, 500 pts)"; \
		echo "  - mdlzork_780124  (Zork 1978-01-24, incomplete end-game)"; \
		echo "  - mdlzork_791211  (Zork 1979-12-11, 616 pts)"; \
		echo "  - mdlzork_810722  (Zork 1981-07-22, final MDL, 585 pts)"; \
		echo ""; \
		echo "Not playable:"; \
		echo "  - mdlzork_780402  (source only, no save files)"; \
		echo ""; \
		echo "Examples:"; \
		echo "  make run-native GAME=mdlzork_810722"; \
		echo "  make run-native GAME=mdlzork_810722 SAVE=MDL/MADADV.SAVE"; \
		echo ""; \
		echo "Note: A save file is REQUIRED to bootstrap the game."; \
		echo "      Default is MDL/MADADV.SAVE if not specified."; \
		exit 1; \
	fi
	@GAME_NAME="$(GAME)"; \
	SAVE_FILE="$(SAVE)"; \
	if [ ! -d "$$GAME_NAME" ]; then \
		echo "Error: Game directory '$$GAME_NAME' not found"; \
		echo "Available games: mdlzork_771212 mdlzork_780124 mdlzork_791211 mdlzork_810722"; \
		exit 1; \
	fi; \
	cd "$$GAME_NAME" && \
	if [ -n "$$SAVE_FILE" ]; then \
		../confusion-mdl/mdli -r "$$SAVE_FILE"; \
	elif [ -f "MDL/MADADV.SAVE" ]; then \
		echo "Using MDL/MADADV.SAVE"; \
		../confusion-mdl/mdli -r "MDL/MADADV.SAVE"; \
	else \
		echo "Error: No save file found (tried MDL/MADADV.SAVE)"; \
		exit 1; \
	fi

# Validate all save files load correctly with the native interpreter
validate: interpreter
	@echo "Validating save files..."
	@FAILURES=0; \
	for game in mdlzork_771212 mdlzork_780124 mdlzork_791211 mdlzork_810722; do \
		if [ -d "$$game" ] && [ -f "$$game/MDL/MADADV.SAVE" ]; then \
			printf "  %s/MDL/MADADV.SAVE ... " "$$game"; \
			if scripts/run-with-timeout.pl 5 sh -c "cd $$game && printf 'QUIT\\n' | ../confusion-mdl/mdli -r MDL/MADADV.SAVE" >/dev/null 2>&1; then \
				echo "✅ OK"; \
			else \
				echo "❌ FAILED"; \
				FAILURES=$$((FAILURES + 1)); \
			fi; \
		else \
			echo "  $$game: skipped (no save file)"; \
		fi; \
	done; \
	if [ $$FAILURES -gt 0 ]; then \
		echo ""; \
		echo "❌ $$FAILURES validation failure(s)"; \
		exit 1; \
	else \
		echo ""; \
		echo "✅ All save files validated"; \
	fi

# Build the MDL interpreter
interpreter: check-submodules check-deps $(CONFUSION_INTERPRETER)

$(CONFUSION_INTERPRETER): check-submodules check-deps
	@echo "Building MDL interpreter..."
	$(MAKE) -C $(CONFUSION_DIR)

# Clean build artifacts and temporary files
clean:
	@echo "Cleaning build artifacts..."
	rm -rf $(BUILD_DIR)
	# Clean legacy build artifacts from previous build layout
	rm -rf wasm-build
	rm -f web/mdli.js web/mdli.wasm web/mdli.data
	find . -type f -name ".DS_Store" -not -path "./emsdk/*" -delete 2>/dev/null || true
	find . -type f -name "*.log" -not -path "./emsdk/*" -delete 2>/dev/null || true
	find . -type f -name "*.backup" -not -path "./emsdk/*" -delete 2>/dev/null || true
	find . -type f -name "*.bak" -not -path "./emsdk/*" -delete 2>/dev/null || true
	@echo "✅ Clean complete"

# Clean everything including compiled interpreter
clean-all: clean
	$(MAKE) -C $(CONFUSION_DIR) clean

# ============================================================================
# WASM Build Targets
# ============================================================================

# Install Emscripten SDK if not present
wasm-deps: $(EMSDK_ACTIVATE)

$(EMSDK_DIR):
	@echo "Installing Emscripten SDK..."
	@echo "This may take 10-15 minutes on first run..."
	git clone https://github.com/emscripten-core/emsdk.git $(EMSDK_DIR)

$(EMSDK_ACTIVATE): $(EMSDK_DIR)
	@echo "Setting up Emscripten SDK..."
	cd $(EMSDK_DIR) && ./emsdk install $(EMSDK_VERSION)
	cd $(EMSDK_DIR) && ./emsdk activate $(EMSDK_VERSION)
	@echo "✅ Emscripten SDK installed and activated"
	@echo ""
	@echo "⚠️  IMPORTANT: Run 'source $(EMSDK_ACTIVATE)' in your shell before building"
	@echo "   Or use: eval $$(make wasm-env)"

# Export Emscripten environment variables
wasm-env:
	@echo "export PATH=\"$$(pwd)/$(EMSDK_DIR)/upstream/emscripten:$$PATH\""
	@echo "export EMSDK=\"$$(pwd)/$(EMSDK_DIR)\""
	@echo "export EM_CONFIG=\"$$(pwd)/$(EMSDK_DIR)/.emscripten\""

# Check if Emscripten is available
check-emscripten:
	@if ! command -v emcc >/dev/null 2>&1; then \
		echo "❌ Emscripten not found in PATH"; \
		echo ""; \
		echo "Please run:"; \
		echo "  source $(EMSDK_ACTIVATE)"; \
		echo ""; \
		echo "Or:"; \
		echo "  eval $$(make wasm-env)"; \
		exit 1; \
	fi
	@echo "✅ Emscripten found: $$(emcc --version | head -1)"

# Build WASM version
wasm-build: check-submodules wasm-deps
	@echo "Building WASM interpreter..."
	@echo "Sourcing Emscripten environment..."
	@for save in \
		mdlzork_771212/MDL/MADADV.SAVE \
		mdlzork_780124/MDL/MADADV.SAVE \
		mdlzork_791211/MDL/MADADV.SAVE \
		mdlzork_810722/MDL/MADADV.SAVE; do \
		if [ ! -f "$$save" ]; then echo "Missing required game file: $$save"; exit 1; fi; \
	done
	@GAME_DIRS=""; \
	for game in mdlzork_771212 mdlzork_780124 mdlzork_791211 mdlzork_810722; do \
		if [ -d "$$game" ]; then \
			GAME_DIRS="$$GAME_DIRS ../$$game"; \
		fi; \
	done; \
	if [ -f $(EMSDK_ACTIVATE) ]; then \
		bash -c 'cd $(EMSDK_DIR) && . ./emsdk_env.sh && cd - > /dev/null && $(MAKE) -C $(CONFUSION_DIR) -f Makefile.wasm BUILD_DIR=../$(WASM_BUILD_DIR) GAME_DIRS="'"$$GAME_DIRS"'"'; \
	else \
		echo "❌ Emscripten not installed. Run 'make wasm-deps' first."; \
		exit 1; \
	fi
	@echo "Verifying WASM build..."
	@if [ ! -f $(WASM_BUILD_DIR)/mdli.js ] || [ ! -f $(WASM_BUILD_DIR)/mdli.wasm ] || [ ! -f $(WASM_BUILD_DIR)/mdli.data ]; then \
		echo "❌ WASM build failed - mdli.js, mdli.wasm, or mdli.data not found in $(WASM_BUILD_DIR)"; \
		exit 1; \
	fi
	@echo "Assembling web application in $(WEB_BUILD_DIR)/..."
	@mkdir -p $(WEB_BUILD_DIR)
	@cp -r web/* $(WEB_BUILD_DIR)/
	@cp $(WASM_BUILD_DIR)/mdli.js $(WASM_BUILD_DIR)/mdli.wasm $(WEB_BUILD_DIR)/
	@cp $(WASM_BUILD_DIR)/mdli.data $(WEB_BUILD_DIR)/
	@echo "✅ Web application assembled in $(WEB_BUILD_DIR)/"

# Serve WASM build for testing
wasm-serve: wasm-build
	@echo ""
	@echo "Starting web server for WASM build..."
	@echo "  📡 Server: http://localhost:$(SERVER_PORT)"
	@echo ""
	@echo "Press Ctrl+C to stop server"
	@echo ""
	python3 -m http.server $(SERVER_PORT) -d $(WEB_BUILD_DIR)

# Clean WASM build artifacts
clean-wasm:
	rm -rf $(BUILD_DIR)

# ============================================================================
# Release Packaging Targets
# ============================================================================

# Release directory structure
RELEASE_DIR := releases
NATIVE_RELEASE_DIR := $(RELEASE_DIR)/native
WASM_RELEASE_DIR := $(RELEASE_DIR)/wasm
VERSION := $(shell git describe --tags --always 2>/dev/null || echo "dev")

# Package native release (interpreter + game files)
package-native: build-native
	@echo "Packaging native release..."
	@mkdir -p $(NATIVE_RELEASE_DIR)/mdlzork-$(VERSION)
	@echo "Copying interpreter..."
	@cp $(CONFUSION_INTERPRETER) $(NATIVE_RELEASE_DIR)/mdlzork-$(VERSION)/mdli
	@chmod +x $(NATIVE_RELEASE_DIR)/mdlzork-$(VERSION)/mdli
	@echo "Copying game files..."
	@cp -r mdlzork_771212 $(NATIVE_RELEASE_DIR)/mdlzork-$(VERSION)/ 2>/dev/null || true
	@cp -r mdlzork_780124 $(NATIVE_RELEASE_DIR)/mdlzork-$(VERSION)/ 2>/dev/null || true
	@cp -r mdlzork_791211 $(NATIVE_RELEASE_DIR)/mdlzork-$(VERSION)/ 2>/dev/null || true
	@cp -r mdlzork_810722 $(NATIVE_RELEASE_DIR)/mdlzork-$(VERSION)/ 2>/dev/null || true
	@echo "Creating launcher scripts..."
	@echo '#!/bin/bash' > $(NATIVE_RELEASE_DIR)/mdlzork-$(VERSION)/play-zork-810722.sh
	@echo 'cd mdlzork_810722' >> $(NATIVE_RELEASE_DIR)/mdlzork-$(VERSION)/play-zork-810722.sh
	@echo '../mdli -r MDL/MADADV.SAVE' >> $(NATIVE_RELEASE_DIR)/mdlzork-$(VERSION)/play-zork-810722.sh
	@chmod +x $(NATIVE_RELEASE_DIR)/mdlzork-$(VERSION)/play-zork-810722.sh
	@echo "✅ Native release packaged: $(NATIVE_RELEASE_DIR)/mdlzork-$(VERSION)/"

# Package WASM release (browser-ready application)
package-wasm: wasm-build
	@echo "Packaging WASM release..."
	@mkdir -p $(WASM_RELEASE_DIR)/mdlzork-$(VERSION)
	@echo "Copying web application..."
	@cp -r $(WEB_BUILD_DIR)/* $(WASM_RELEASE_DIR)/mdlzork-$(VERSION)/
	@echo "✅ WASM release packaged: $(WASM_RELEASE_DIR)/mdlzork-$(VERSION)/"

# Package both releases
package: package-native package-wasm
	@echo ""
	@echo "✅ All releases packaged!"
	@echo ""
	@echo "Native release: $(NATIVE_RELEASE_DIR)/mdlzork-$(VERSION)/"
	@echo "WASM release: $(WASM_RELEASE_DIR)/mdlzork-$(VERSION)/"

# Clean release artifacts
clean-releases:
	rm -rf $(RELEASE_DIR)

# Help target
help:
	@echo "MDL Zork Build System"
	@echo ""
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo "High-Level Targets:"
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo "  make build        - Build browser-ready WASM application"
	@echo "  make run          - Build and serve WASM application in browser"
	@echo "  make build-native - Build native CLI interpreter"
	@echo "  make run-native   - Run native CLI version (interactive)"
	@echo "  make validate     - Test all save files load correctly"
	@echo ""
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo "WASM Build Targets:"
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo "  make wasm-deps    - Install Emscripten SDK (first time only)"
	@echo "  make wasm-build   - Build WASM version"
	@echo "  make wasm-serve   - Build WASM and start test server"
	@echo ""
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo "Release Packaging:"
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo "  make package-native - Package native release (interpreter + games)"
	@echo "  make package-wasm   - Package WASM release (browser-ready)"
	@echo "  make package        - Package both native and WASM releases"
	@echo ""
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo "Maintenance:"
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo "  make clean          - Clean build artifacts"
	@echo "  make clean-wasm     - Clean WASM build artifacts"
	@echo "  make clean-all      - Clean everything"
	@echo "  make clean-releases - Clean release artifacts"
	@echo "  make install-deps   - Install build dependencies"
	@echo ""
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo "Quick Start:"
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo "  Browser:  make run"
	@echo "  Native:   make build-native && make run-native GAME=mdlzork_810722"
