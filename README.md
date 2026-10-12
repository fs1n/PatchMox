# PatchMox

![Proxmox](https://img.shields.io/badge/proxmox-proxmox?style=for-the-badge&logo=proxmox&logoColor=%23E57000&labelColor=%232b2a33&color=%232b2a33)
![Bash Script](https://img.shields.io/badge/bash_script-%23121011.svg?style=for-the-badge&logo=gnu-bash&logoColor=white)
![License](https://img.shields.io/badge/license-MIT-green?style=for-the-badge)

PatchMox is a host-side Bash orchestrator for **Proxmox VE** that keeps Windows VMs up to date with the latest **VirtIO drivers** and **QEMU Guest Agent** releases.

It discovers Windows VMs automatically, queries installed versions via the QEMU Guest Agent, fetches the latest releases from the [Fedora People Archive](https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/), and renders SVG update banners directly inside the Proxmox VE UI.

## What works

- Automatic discovery of Windows VMs on the Proxmox cluster
- Installed VirtIO / QEMU Guest Agent version detection via QEMU Guest Agent
- Latest version lookup from the Fedora People Archive
- SVG update banners in the Proxmox UI
- Persistent per-VM state with `vmgenid` clone/restore detection
- Version fetch caching to avoid repeated network requests
- Filesystem-based job queue with `patchmox worker`
- Policy-driven decisions (default: notify-only)
- Notifications via SMTP and outgoing webhook (JSON)

## What is not ready

- In-VM auto-update execution is a stub; the worker calls a placeholder action
- Node-level concurrency for large clusters is planned

See [`PLAN.md`](PLAN.md) for the full roadmap.

## Quick start

```bash
git clone https://github.com/fs1n/PVE-QEMU-VirtIO-Updater.git /opt/patchmox
cd /opt/patchmox
cp .env.example .env
nano .env
chmod +x bin/patchmox install.sh
./install.sh
patchmox check
```

### Debian package

Download the `.deb` from the [releases](https://github.com/fs1n/PatchMox/releases) page and install it on the Proxmox node:

```bash
apt install ./patchmox_<version>_all.deb
nano /etc/patchmox/patchmox.env
patchmox check
systemctl enable --now patchmox.timer   # daily check at ~06:00
```

| Path | Content |
|------|---------|
| `/etc/patchmox/patchmox.env` | Configuration (kept on upgrade) |
| `/etc/patchmox/policies/` | Policies |
| `/var/lib/patchmox/` | State and job queue |
| `/var/log/patchmox/` | Logs |

Build it yourself with [nfpm](https://nfpm.goreleaser.com/): `packaging/build-deb.sh`. Pushing a `v*` tag builds the package in CI and attaches it to a GitHub release.

### Upgrading from the legacy scripts

The wrappers `check-vm-updates.sh` and `vm-update.sh` have been removed, together with the inbound "click to update" webhook. If a cron job or systemd timer still calls them, switch it to the CLI:

```bash
# before
/opt/patchmox/check-vm-updates.sh
# after
/opt/patchmox/bin/patchmox check
```

Leftovers on existing hosts can be removed manually: `/opt/patchmox/check-vm-updates.sh`, `/opt/patchmox/vm-update.sh`, `/opt/patchmox/webhook/` and the `patchmox-webhook.service` unit.

## Documentation

- [Installation](docs/installation.md)
- [Configuration](docs/configuration.md)
- [Architecture](docs/architecture.md)
- [CLI usage](docs/cli-usage.md)
- [Development plan](PLAN.md)

## Example

```bash
# Check all running Windows VMs
patchmox check

# Check a specific VM, bypassing the version cache
patchmox check --vmid 100 --force-refresh

# Process one pending auto-update job
patchmox worker --once

# Show stored state for a VM
patchmox state --vmid 100
```

## Requirements

- Proxmox VE 8.0+
- Bash 4+
- `jq`, `curl`, `pvesh`, `qm`
- Windows guests with QEMU Guest Agent and VirtIO drivers installed

## License

MIT — see [LICENSE](LICENSE).
