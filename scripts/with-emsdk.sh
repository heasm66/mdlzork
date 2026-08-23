#!/bin/bash
# Wrapper script to run commands with Emscripten environment activated
# Usage: ./scripts/with-emsdk.sh <command> [args...]

set -e

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
EMSDK_DIR="$PROJECT_ROOT/emsdk"
EMSDK_ACTIVATE="$EMSDK_DIR/emsdk_env.sh"

# Check if emsdk is installed
if [ ! -f "$EMSDK_ACTIVATE" ]; then
    echo "❌ Emscripten SDK not found at $EMSDK_DIR"
    echo ""
    echo "Please run: make wasm-deps"
    exit 1
fi

# Source Emscripten environment
# Suppress output unless there's an error
if ! . "$EMSDK_ACTIVATE" >/dev/null 2>&1; then
    echo "❌ Failed to activate Emscripten environment"
    exit 1
fi

# Run the provided command with all arguments
exec "$@"
