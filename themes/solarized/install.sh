#!/usr/bin/env bash
# Install the Solarized Dark/Light schemes for KDE Plasma and Konsole.
# Then pick them in System Settings -> Colors, or: plasma-apply-colorscheme SolarizedDark
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
mkdir -p ~/.local/share/color-schemes ~/.local/share/konsole
cp "$here"/*.colors ~/.local/share/color-schemes/
cp "$here"/*.colorscheme ~/.local/share/konsole/
echo "installed: SolarizedDark, SolarizedLight (Plasma + Konsole)"
