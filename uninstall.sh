#!/usr/bin/env bash
set -euo pipefail

EXTENSION_DIR="/usr/local/psa/admin/htdocs/modules/flowtriq"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info()  { echo -e "${GREEN}[flowtriq]${NC} $1"; }
warn()  { echo -e "${YELLOW}[flowtriq]${NC} $1"; }
error() { echo -e "${RED}[flowtriq]${NC} $1"; exit 1; }

[[ $EUID -ne 0 ]] && error "This script must be run as root."

info "Uninstalling Flowtriq..."

# ── Stop and disable ftagent service ──────────────────────────────────────
if systemctl is-active --quiet ftagent 2>/dev/null; then
    info "Stopping ftagent service..."
    systemctl stop ftagent
fi

if systemctl is-enabled --quiet ftagent 2>/dev/null; then
    info "Disabling ftagent service..."
    systemctl disable ftagent
fi

# ── Unregister and remove Plesk extension ─────────────────────────────────
if command -v plesk &>/dev/null; then
    info "Unregistering Plesk extension..."
    plesk bin extension --unregister flowtriq 2>/dev/null || true
fi

if [[ -d "$EXTENSION_DIR" ]]; then
    info "Removing extension files..."
    rm -rf "$EXTENSION_DIR"
fi

# ── Uninstall ftagent ────────────────────────────────────────────────────
info "Uninstalling ftagent..."
python3 -m pip uninstall -y ftagent 2>/dev/null || pip3 uninstall -y ftagent 2>/dev/null || true

# ── Clean up service file ────────────────────────────────────────────────
if [[ -f /etc/systemd/system/ftagent.service ]]; then
    info "Removing systemd service file..."
    rm -f /etc/systemd/system/ftagent.service
    systemctl daemon-reload
fi

# ── Clean up config ──────────────────────────────────────────────────────
if [[ -d /etc/ftagent ]]; then
    read -rp "Remove ftagent configuration in /etc/ftagent? [y/N] " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        rm -rf /etc/ftagent
        info "Configuration removed."
    else
        info "Configuration preserved at /etc/ftagent."
    fi
fi

echo ""
info "Flowtriq has been removed from this server."
echo ""
