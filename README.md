# Flowtriq for Plesk

DDoS detection and auto-mitigation for Plesk servers. This extension installs the Flowtriq agent (`ftagent`) on your server and adds a status panel directly inside Plesk.

## What it does

Plesk servers host websites and are frequent targets for volumetric and application-layer DDoS attacks. Flowtriq monitors your server's traffic in real time, detects attacks as they start, sends alerts, and can trigger automatic mitigation through your upstream provider or local firewall rules.

This integration gives you:

- **One-command install** that sets up the agent and registers the Plesk extension
- **In-panel status** showing agent health, version, last heartbeat, and recent incidents
- **Service controls** to start, stop, or restart the agent from the Plesk UI
- **Direct link** to the full Flowtriq dashboard for deep traffic analytics

## Architecture

```
┌─────────────────────────────────────────────┐
│  Plesk Server                               │
│                                             │
│  ┌──────────────┐    ┌──────────────────┐   │
│  │ Plesk Panel  │    │ ftagent          │   │
│  │              │    │ (systemd service)│   │
│  │  Flowtriq    │    │                  │   │
│  │  Extension ──┼────▶ Status / Control │   │
│  │              │    │                  │   │
│  └──────────────┘    └───────┬──────────┘   │
│                              │              │
└──────────────────────────────┼──────────────┘
                               │ HTTPS
                               ▼
                    ┌──────────────────┐
                    │ Flowtriq Cloud   │
                    │ dash.flowtriq.com│
                    └──────────────────┘
```

## Quick install

```bash
curl -fsSL https://raw.githubusercontent.com/Flowtriq/flowtriq-plesk/main/install.sh | bash
```

This will:

1. Verify Plesk is installed
2. Install `ftagent` via pip
3. Run interactive setup (`ftagent --setup`)
4. Enable and start the agent as a systemd service
5. Install the Plesk extension
6. Register the extension with the Plesk panel

## Manual install

```bash
# Install the agent
pip3 install ftagent
ftagent --setup

# Enable the service
systemctl enable ftagent
systemctl start ftagent

# Install the extension
git clone https://github.com/Flowtriq/flowtriq-plesk.git /tmp/flowtriq-plesk
cp -r /tmp/flowtriq-plesk/plesk-extension /usr/local/psa/admin/htdocs/modules/flowtriq
chown -R psaadm:psaadm /usr/local/psa/admin/htdocs/modules/flowtriq
plesk bin extension --register flowtriq
```

## Uninstall

```bash
curl -fsSL https://raw.githubusercontent.com/Flowtriq/flowtriq-plesk/main/uninstall.sh | bash
```

Or run `uninstall.sh` from a local clone.

## What you get

| Feature | Description |
|---|---|
| Real-time monitoring | Continuous traffic analysis on the server |
| Attack detection | Identifies volumetric floods, SYN floods, and application-layer attacks |
| Alerts | Instant notifications when an incident is detected |
| Auto-mitigation | Triggers upstream or local firewall rules to drop attack traffic |
| Plesk panel | View agent status, control the service, and link to the full dashboard |

## Requirements

- **Plesk Obsidian 18.0+**
- **OS:** Ubuntu 20.04+, Debian 10+, CentOS 7+, AlmaLinux 8+, Rocky Linux 8+
- **Python 3.6+** (installed automatically if missing)
- **Root access**
- A Flowtriq account (sign up at [flowtriq.com](https://flowtriq.com))

## FAQ

**How much overhead does the agent add?**
Minimal. The agent uses well under 1% CPU and around 30 MB of memory during normal operation. It is designed for production servers and will not interfere with your hosted sites.

**Does it work alongside other Plesk extensions?**
Yes. The Flowtriq extension is a standard Plesk module and does not conflict with other extensions, security tools, or Plesk features.

**Does it work with both Nginx and Apache?**
Yes. The agent monitors traffic at the network level, so it works regardless of which web server Plesk is configured to use (Nginx, Apache, or Nginx as a reverse proxy for Apache).

**Can I manage multiple Plesk servers from one dashboard?**
Yes. Each server runs its own agent, and all of them report to the same Flowtriq dashboard at [dash.flowtriq.com](https://dash.flowtriq.com) where you can see every node in one view.

## Links

- [Flowtriq website](https://flowtriq.com)
- [Dashboard](https://dash.flowtriq.com)
- [ftagent on PyPI](https://pypi.org/project/ftagent/)
- [Documentation](https://docs.flowtriq.com)
- [Support](mailto:support@flowtriq.com)

## License

[MIT](LICENSE)
