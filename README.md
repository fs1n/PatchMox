# PatchMox

![Proxmox](https://img.shields.io/badge/proxmox-proxmox?style=for-the-badge&logo=proxmox&logoColor=%23E57000&labelColor=%232b2a33&color=%232b2a33)
![Bash Script](https://img.shields.io/badge/bash_script-%23121011.svg?style=for-the-badge&logo=gnu-bash&logoColor=white)
![License](https://img.shields.io/badge/license-MIT-green?style=for-the-badge)

PatchMox is a host-side Bash orchestrator for **Proxmox VE** that keeps Windows VMs up to date with the latest **VirtIO drivers** and **QEMU Guest Agent** releases.

It discovers Windows VMs automatically, queries installed versions via the QEMU Guest Agent, fetches the latest releases from the [Fedora People Archive](https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/), and renders SVG update banners directly inside the Proxmox VE UI.

## Quick start

```bash
<-- ADD PATCHMOX REPO -->
apt update && apt install -y PatchMox
patchmox check
```

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

MIT - see [LICENSE](LICENSE)
