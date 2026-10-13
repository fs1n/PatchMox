# CLI Usage

PatchMox has one entry point: `bin/patchmox`.

```bash
patchmox check [--vmid ID] [--force-refresh]
patchmox notify [--test] [--channel smtp|webhook]
patchmox worker [--once] [--max-jobs N] [--daemon]
patchmox apply --vmid ID [--component virtio|qemu-ga]
patchmox policy --dry-run [--vmid ID]
patchmox state --vmid ID
patchmox cleanup [--dry-run] [--vmid ID]
patchmox version
patchmox help
```

## `patchmox check`

Main orchestration. Discovers Windows VMs, fetches latest versions, compares, shows/removes SVG nags, persists state, and enqueues auto-update jobs if the policy allows.

```bash
# All running Windows VMs
patchmox check

# Only VM 100
patchmox check --vmid 100

# Bypass version cache
patchmox check --force-refresh
```

Interactive terminals show a spinner and per-VM progress. Logs go to file and journal by default; set `PATCHMOX_CONSOLE_LOG=true` to also print to the terminal.

## `patchmox worker`

Processes update jobs from `queue/pending/`.

```bash
# Process one eligible job and exit
patchmox worker --once

# Process up to 5 jobs
patchmox worker --max-jobs 5

# Run as daemon
patchmox worker --daemon
```

## `patchmox notify`

Sends notifications through the configured channels (`NOTIFICATION_CHANNELS`).

```bash
# Send a test notification through all configured channels
patchmox notify --test

# Test only the webhook channel
patchmox notify --test --channel webhook

# Send a summary of currently active update nags
patchmox notify
```

The summary includes all VMs where the SVG nag is currently active. Channel settings are read from the config file (`.env` or `/etc/patchmox/patchmox.env`).

## `patchmox apply`

Phase 1 stub. Manually trigger an update for a VM.

```bash
patchmox apply --vmid 100 --component virtio
```

## `patchmox policy`

Evaluate a sample event against loaded policies.

```bash
patchmox policy --dry-run --vmid 100
```

## `patchmox state`

Show persisted state for a VM.

```bash
patchmox state --vmid 100
```

## `patchmox cleanup`

Removes everything PatchMox put into Proxmox: the update banner in every VM description (all nodes, running and stopped VMs, also old clickable banners from the removed webhook integration) and the rendered `update-<vmid>.svg` images on this node. Other description text is kept. The stored state is marked as "no banner".

```bash
# Show what would be removed
patchmox cleanup --dry-run

# Remove all banners
patchmox cleanup

# Only one VM
patchmox cleanup --vmid 100
```

The Debian package runs `patchmox cleanup` automatically on `apt remove`. On a cluster, banner images live on the node that ran PatchMox; run `cleanup` there (descriptions are cleaned cluster-wide from any node).

Note: the next `patchmox check` shows banners again for VMs that still need updates - stop the timer first if you want them gone for good.

## `patchmox version`

Prints the installed version.

## Shell completion

Bash completion for commands, options and VM IDs is installed with the Debian package (`/usr/share/bash-completion/completions/patchmox`) and by `install.sh` (`/etc/bash_completion.d/patchmox`). It is active in new shells. VM IDs after `--vmid` come from the cluster VM list `/etc/pve/.vmlist` (QEMU VMs only), so completion needs no API call.
