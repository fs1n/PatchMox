# Installation

PatchMox runs on a Proxmox VE node. It needs root-equivalent privileges because it queries the Proxmox API, executes guest-agent commands inside VMs, and writes SVG banners into `/usr/share/pve-manager/images/`.

## Requirements

### Host (Proxmox VE node)

- Proxmox VE 8.0+ (tested on 8.x and 9.x)
- Bash 4+
- `jq`, `curl`, `pvesh`, `sed`, `awk`, `grep`
- Network access to `https://fedorapeople.org` for version checks

### Guest (Windows VMs)

- Windows 10/11 or Windows Server 2022+
- PowerShell 5+
- QEMU Guest Agent installed and running
- VirtIO drivers installed via the VirtIO installer

## Debian package (recommended)

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
| `/etc/patchmox/policies.d/` | Your own policies (a file named like a built-in one replaces it) |
| `/usr/share/patchmox/policies/` | Built-in policies |
| `/var/lib/patchmox/` | State and job queue |
| `/var/log/patchmox/` | Logs |

`patchmox version` shows the installed version. Build the package yourself with [nfpm](https://nfpm.goreleaser.com/): `packaging/build-deb.sh`. Pushing a `v*` tag builds the package in CI (version = tag) and attaches it to a GitHub release.

## Quick install (git)

```bash
# Clone to /opt/patchmox (recommended production location)
git clone https://github.com/fs1n/PVE-QEMU-VirtIO-Updater.git /opt/patchmox
cd /opt/patchmox

# Create your config
cp .env.example .env
nano .env

# Make the CLI executable and link it into PATH
chmod +x bin/patchmox install.sh
./install.sh

# Test
patchmox check
```

`install.sh` copies the current checkout to `/opt/patchmox`, ensures executables are executable, creates `.env` from `.env.example` if missing, and symlinks `bin/patchmox` to `/usr/local/bin/patchmox`.

## Schedule

### Cron

```bash
# Run daily at 02:00
0 2 * * * /opt/patchmox/bin/patchmox check
```

### systemd timer (recommended)

See `systemd/patchmox-check.service` and `systemd/patchmox-check.timer` (create these in `/etc/systemd/system/`):

```ini
# patchmox-check.service
[Unit]
Description=PatchMox update check
After=network.target

[Service]
Type=oneshot
ExecStart=/opt/patchmox/bin/patchmox check
WorkingDirectory=/opt/patchmox
```

```ini
# patchmox-check.timer
[Unit]
Description=Run PatchMox update check daily

[Timer]
OnCalendar=daily
Persistent=true

[Install]
WantedBy=timers.target
```

Enable and start:

```bash
systemctl daemon-reload
systemctl enable --now patchmox-check.timer
```

## Upgrade

```bash
cd /opt/patchmox
git pull
# Re-run install if new files were added
./install.sh
```

## Uninstall

Debian package: `apt remove patchmox` (banners are removed automatically), `apt purge patchmox` also deletes config, state and logs.

Git install:

```bash
patchmox cleanup          # remove update banners from all VMs
rm /usr/local/bin/patchmox
rm -rf /opt/patchmox
rm -rf /etc/systemd/system/patchmox-check.*
systemctl daemon-reload
```

## Upgrading from the legacy scripts

The wrappers `check-vm-updates.sh` and `vm-update.sh` have been removed, together with the inbound "click to update" webhook. If a cron job or systemd timer still calls them, switch it to the CLI:

```bash
# before
/opt/patchmox/check-vm-updates.sh
# after
/opt/patchmox/bin/patchmox check
```

Old clickable banners are removed with `patchmox cleanup` (the next check adds the new ones). Leftovers on existing hosts can be removed manually: `/opt/patchmox/check-vm-updates.sh`, `/opt/patchmox/vm-update.sh`, `/opt/patchmox/webhook/` and the `patchmox-webhook.service` unit.
