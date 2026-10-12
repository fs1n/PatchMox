# Configuration

PatchMox is configured through a single `.env` file in the project root (`/opt/patchmox/.env`). Copy `.env.example` and adjust.

```bash
cp .env.example .env
nano .env
```

## Key settings

### Logging

| Variable | Default | Meaning |
|----------|---------|---------|
| `LOG_DIR` | `<patchmox>/logs` | Where `patchmox.log` lives |
| `LOG_LEVEL` | `info` | `debug`, `info`, `notice`, `warn`, `error` |
| `PATCHMOX_CONSOLE_LOG` | `false` | Print log lines to the terminal; default is file + journal only |
| `USE_JOURNAL` | `true` | Log to systemd journal with tag `PatchMox` |
| `JOURNAL_TAG` | `PatchMox` | Journal tag |

Keep `PATCHMOX_CONSOLE_LOG=false` for cron/systemd. Set it to `true` when running interactively and debugging.

### State and queue

| Variable | Default | Meaning |
|----------|---------|---------|
| `STATE_DIR` | `<patchmox>/.state` | Per-VM state files and version cache |
| `QUEUE_DIR` | `<patchmox>/queue` | Job queue directories |

### Version fetch cache

| Variable | Default | Meaning |
|----------|---------|---------|
| `VERSION_CACHE_TTL_MINUTES` | `60` | How long fetched VirtIO/QEMU-GA versions are reused |
| `VERSION_CACHE_FORCE_REFRESH` | `false` | Always fetch fresh versions on the next run |

This avoids hitting the Fedora People Archive on every cron tick.

### Guest agent cache

| Variable | Default | Meaning |
|----------|---------|---------|
| `GUEST_AGENT_CACHE_TTL_MINUTES` | `60` | How long queried VirtIO/QEMU-GA versions per VM are reused |
| `GUEST_AGENT_CACHE_FORCE_REFRESH` | `false` | Always query the guest agent on the next run |

This skips `qm guest exec` calls for VMs that were recently checked and have not changed (same `vmgenid`, still running). It is the highest-impact performance optimization for daily cron schedules.

### SVG banners

| Variable | Default | Meaning |
|----------|---------|---------|
| `SVG_IMAGE_PATH` | `/usr/share/pve-manager/images/` | Where rendered SVGs are written |
| `SVG_IMAGE_TEMPLATE` | `<patchmox>/templates/svg/update-nag-template.svg` | Single-update template |

### Notifications

| Variable | Purpose |
|----------|---------|
| `NOTIFICATION_CHANNELS` | Comma-separated list, e.g. `smtp,webhook` |
| `SMTP_HOST`, `SMTP_PORT`, `SMTP_USER`, `SMTP_PASSWORD`, `SMTP_FROM` | SMTP settings |
| `MAIL_TO` | Comma-separated list of recipients (string recommended) |
| `MSGRAPH_*` | Microsoft Graph mail settings (stub) |
| `WEBHOOK_*` | Outgoing webhook settings (see below) |

SMTP and webhook are fully implemented; MS Graph is a stub. SMTP TLS mode is derived from `SMTP_PORT`:

- 25 → opportunistic STARTTLS
- 587 → required STARTTLS (default)
- 465 → implicit TLS

### Outgoing webhook

When `webhook` is listed in `NOTIFICATION_CHANNELS`, every notification (e.g. `update.available`) is sent as JSON to `WEBHOOK_URL`. The webhook only notifies; it does not trigger updates.

| Variable | Default | Meaning |
|----------|---------|---------|
| `WEBHOOK_URL` | — | Target URL (required) |
| `WEBHOOK_METHOD` | `POST` | HTTP method |
| `WEBHOOK_HEADERS` | — | Extra headers as JSON object, e.g. `{"Authorization": "Bearer ..."}` |
| `WEBHOOK_TIMEOUT` | `10` | Request timeout in seconds |

Payload:

```json
{
  "source": "patchmox",
  "host": "pve01",
  "subject": "PatchMox: update.available",
  "message": "PatchMox detected available updates for VM 101 on node pve01. ...",
  "text": "PatchMox: update.available\n\nPatchMox detected available updates ...",
  "event": {
    "event_id": "…",
    "timestamp": "2026-10-12T08:00:00Z",
    "type": "update.available",
    "payload": { "vmid": "101", "node": "pve01", "components": ["virtio"], "current": {…}, "latest": {…} }
  }
}
```

`text` makes the payload work directly with Slack, Mattermost and Rocket.Chat incoming webhooks. `event` is `null` for non-event notifications (test, summary). Any non-2xx response is logged as an error.

Test the setup with `patchmox notify --test --channel webhook`.

## Performance tuning

For large clusters or frequent cron schedules:

- Lower `VERSION_CACHE_TTL_MINUTES` if you want fresher version data.
- Keep `PATCHMOX_NO_PROGRESS=1` for non-interactive shells.
- Use `--force-refresh` only when you explicitly want to bypass caches.

A future release will add a guest-agent per-VM cache and optional node-level concurrency.
