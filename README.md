<h1 align="center">Flowtriq for Plesk</h1>

<h3 align="center">DDoS detection for your Plesk server.</h3>

<p align="center">
  <a href="#quick-start">Quick Start</a> &bull;
  <a href="#plesk-extension">Plesk Extension</a> &bull;
  <a href="#what-you-get">Features</a> &bull;
  <a href="#troubleshooting">Troubleshooting</a> &bull;
  <a href="https://discord.gg/SsTWMYuyGG">Discord</a>
</p>

<p align="center">
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue?style=flat-square" alt="License"></a>
  <a href="https://flowtriq.com"><img src="https://img.shields.io/badge/flowtriq-dashboard-00d4aa?style=flat-square" alt="Dashboard"></a>
  <a href="https://pypi.org/project/ftagent/"><img src="https://img.shields.io/pypi/v/ftagent?style=flat-square&label=ftagent&color=3776AB" alt="ftagent"></a>
  <a href="https://discord.gg/SsTWMYuyGG"><img src="https://img.shields.io/badge/discord-join-5865F2?style=flat-square" alt="Discord"></a>
</p>

<p align="center">
  <b><a href="https://flowtriq.com/integrations/plesk">Integration Guide</a></b> | <b><a href="https://flowtriq.com/docs">Documentation</a></b> | <b><a href="https://flowtriq.com/signup">Sign Up</a></b>
</p>

---

<p align="center">
  <img src="https://raw.githubusercontent.com/Flowtriq/flowtriq-plesk/main/.github/architecture.svg" alt="Architecture" width="680">
</p>

---

Plesk servers host websites and are frequent targets for volumetric and application-layer DDoS attacks. This integration installs [ftagent](https://github.com/Flowtriq/ftagent) as a lightweight systemd service on your server, monitors traffic in real time, and reports to the [Flowtriq dashboard](https://flowtriq.com). A Plesk extension gives you at-a-glance status and service controls directly in your hosting panel.

## Quick Start

SSH into your Plesk server as root and run:

```bash
curl -fsSL https://raw.githubusercontent.com/Flowtriq/flowtriq-plesk/main/install.sh | bash
```

The installer will:

1. Verify Plesk is installed
2. Install ftagent via pip
3. Run interactive setup (`ftagent --setup`)
4. Enable and start the agent as a systemd service
5. Install and register the Plesk extension

## Manual Install

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

## Plesk Extension

The extension appears in the Plesk panel and shows:

| | |
|---|---|
| **Agent Health** | Running/stopped indicator with last heartbeat |
| **Agent Version** | Currently installed ftagent version |
| **Recent Incidents** | Attacks detected in the last 24 hours |
| **Service Controls** | Start, stop, and restart buttons |
| **Dashboard Link** | Direct link to the full Flowtriq dashboard |

## What You Get

| | |
|---|---|
| **Real-time Monitoring** | Continuous traffic analysis on the server |
| **Attack Detection** | Volumetric floods, SYN floods, and application-layer attacks |
| **Alerting** | Instant notifications when an incident is detected |
| **Auto-Mitigation** | Upstream or local firewall rules to drop attack traffic |
| **Plesk Panel** | Agent status, service controls, and dashboard link |
| **Web Dashboard** | Full analytics at [dash.flowtriq.com](https://dash.flowtriq.com) |

## Requirements

| Requirement | Details |
|---|---|
| **Plesk** | Obsidian 18.0+ |
| **OS** | Ubuntu 20.04+, Debian 10+, CentOS 7+, AlmaLinux 8+, Rocky Linux 8+ |
| **Python** | 3.6+ (installed automatically if missing) |
| **Access** | Root |
| **Account** | Free Flowtriq account at [flowtriq.com](https://flowtriq.com) |

## Troubleshooting

<details>
<summary><b>ftagent service not starting</b></summary>

```bash
# Check service status
systemctl status ftagent

# View recent logs
journalctl -u ftagent --no-pager -n 30

# Verify the binary is installed
which ftagent
```

</details>

<details>
<summary><b>Plesk extension not appearing</b></summary>

```bash
# Verify the extension directory exists
ls -la /usr/local/psa/admin/htdocs/modules/flowtriq/

# Re-register the extension
plesk bin extension --register flowtriq

# Restart Plesk
systemctl restart psa
```

</details>

<details>
<summary><b>No incidents showing in dashboard</b></summary>

- Verify the agent is running: `systemctl status ftagent`
- Check that your API key is correct: `cat /etc/ftagent/config.json`
- Confirm the server can reach the Flowtriq API: `curl -s https://api.flowtriq.com/health`

</details>

<details>
<summary><b>Nginx and Apache compatibility</b></summary>

The agent monitors traffic at the network level, so it works regardless of which web server Plesk is configured to use (Nginx, Apache, or Nginx as a reverse proxy for Apache). No special configuration needed.

</details>

## Uninstall

```bash
curl -fsSL https://raw.githubusercontent.com/Flowtriq/flowtriq-plesk/main/uninstall.sh | bash
```

Or run `uninstall.sh` from a local clone.

## FAQ

<details>
<summary><b>How much overhead does the agent add?</b></summary>

Minimal. The agent uses well under 1% CPU and around 30 MB of memory during normal operation. It is designed for production servers and will not interfere with your hosted sites.

</details>

<details>
<summary><b>Does it work alongside other Plesk extensions?</b></summary>

Yes. The Flowtriq extension is a standard Plesk module and does not conflict with other extensions, security tools, or Plesk features.

</details>

<details>
<summary><b>Can I manage multiple Plesk servers from one dashboard?</b></summary>

Yes. Each server runs its own agent, and all of them report to the same Flowtriq dashboard where you can see every node in one view.

</details>

<details>
<summary><b>Where do I get my API key?</b></summary>

Sign up at [flowtriq.com](https://flowtriq.com), then go to **Settings > API** in your dashboard.

</details>

<details>
<summary><b>How do I update ftagent?</b></summary>

```bash
pip3 install --upgrade ftagent
systemctl restart ftagent
```

</details>

## Links

- [Flowtriq Website](https://flowtriq.com)
- [Dashboard](https://dash.flowtriq.com)
- [Documentation](https://flowtriq.com/docs)
- [Discord Community](https://discord.gg/SsTWMYuyGG)
- [ftagent on PyPI](https://pypi.org/project/ftagent/)

## Get Started

Start your free 14-day trial at [flowtriq.com/signup](https://flowtriq.com/signup).

## License

MIT. See [LICENSE](LICENSE).

---

Built by [Flowtriq](https://flowtriq.com) - Real-time DDoS detection and mitigation.
