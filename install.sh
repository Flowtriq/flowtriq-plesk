#!/usr/bin/env bash
set -euo pipefail

EXTENSION_DIR="/usr/local/psa/admin/htdocs/modules/flowtriq"
REPO_URL="https://raw.githubusercontent.com/Flowtriq/flowtriq-plesk/main"

# ── Colors ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info()  { echo -e "${GREEN}[flowtriq]${NC} $1"; }
warn()  { echo -e "${YELLOW}[flowtriq]${NC} $1"; }
error() { echo -e "${RED}[flowtriq]${NC} $1"; exit 1; }

# ── Pre-flight checks ──────────────────────────────────────────────────────
[[ $EUID -ne 0 ]] && error "This script must be run as root."

if [[ ! -d /usr/local/psa ]]; then
    error "Plesk is not installed on this server. Aborting."
fi

info "Plesk detected. Starting Flowtriq installation..."

# ── Detect package manager ─────────────────────────────────────────────────
if command -v apt-get &>/dev/null; then
    PKG_MANAGER="apt"
elif command -v yum &>/dev/null; then
    PKG_MANAGER="yum"
elif command -v dnf &>/dev/null; then
    PKG_MANAGER="dnf"
else
    error "Unsupported package manager. This script supports apt, yum, and dnf."
fi

# ── Install Python/pip if missing ──────────────────────────────────────────
if ! command -v python3 &>/dev/null; then
    info "Installing Python 3..."
    case "$PKG_MANAGER" in
        apt) apt-get update -qq && apt-get install -y -qq python3 python3-pip ;;
        yum) yum install -y -q python3 python3-pip ;;
        dnf) dnf install -y -q python3 python3-pip ;;
    esac
fi

if ! command -v pip3 &>/dev/null && ! python3 -m pip --version &>/dev/null 2>&1; then
    info "Installing pip..."
    case "$PKG_MANAGER" in
        apt) apt-get install -y -qq python3-pip ;;
        yum) yum install -y -q python3-pip ;;
        dnf) dnf install -y -q python3-pip ;;
    esac
fi

# ── Install ftagent ────────────────────────────────────────────────────────
info "Installing ftagent..."
python3 -m pip install --upgrade ftagent 2>/dev/null || pip3 install --upgrade ftagent

# ── Run setup ──────────────────────────────────────────────────────────────
info "Running ftagent setup..."
ftagent --setup

# ── Enable and start the systemd service ───────────────────────────────────
info "Enabling ftagent service..."
if [[ -f /etc/systemd/system/ftagent.service ]]; then
    systemctl daemon-reload
    systemctl enable ftagent
    systemctl start ftagent
    info "ftagent service is running."
else
    warn "ftagent systemd service file not found. You may need to start ftagent manually."
fi

# ── Install Plesk extension ───────────────────────────────────────────────
info "Installing Plesk extension..."

if [[ -d "$EXTENSION_DIR" ]]; then
    rm -rf "$EXTENSION_DIR"
fi

mkdir -p "$EXTENSION_DIR"

# Download extension files from the repository
EXTENSION_FILES=(
    "plesk-extension/meta.xml"
    "plesk-extension/plib/controllers/IndexController.php"
    "plesk-extension/plib/views/scripts/index/index.phtml"
)

for file in "${EXTENSION_FILES[@]}"; do
    dest="$EXTENSION_DIR/${file#plesk-extension/}"
    mkdir -p "$(dirname "$dest")"
    curl -fsSL "$REPO_URL/$file" -o "$dest"
done

# Set permissions
chown -R psaadm:psaadm "$EXTENSION_DIR"
chmod -R 755 "$EXTENSION_DIR"

# Register the extension with Plesk
if command -v plesk &>/dev/null; then
    plesk bin extension --register flowtriq 2>/dev/null || true
    info "Extension registered with Plesk."
else
    warn "Could not register extension automatically. It should appear after Plesk restart."
fi

# ── Done ───────────────────────────────────────────────────────────────────
echo ""
info "Installation complete!"
echo ""
echo "  What's running:"
echo "    - ftagent is monitoring traffic on this server"
echo "    - The Flowtriq extension is available in your Plesk panel"
echo ""
echo "  Next steps:"
echo "    1. Log into Plesk and find 'Flowtriq DDoS Detection' under Extensions"
echo "    2. View your dashboard at https://dash.flowtriq.com"
echo ""
