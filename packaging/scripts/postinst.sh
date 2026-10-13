#!/bin/sh
set -e

mkdir -p /var/lib/patchmox/state /var/lib/patchmox/queue /var/log/patchmox
chmod 0640 /etc/patchmox/patchmox.env 2>/dev/null || true

if [ -d /run/systemd/system ]; then
    systemctl daemon-reload >/dev/null 2>&1 || true
fi

# First install only: the timer is NOT enabled automatically, because
# PatchMox writes update banners into VM descriptions.
if [ "$1" = "configure" ] && [ -z "$2" ]; then
    echo "PatchMox installed."
    echo "  1. Edit /etc/patchmox/patchmox.env (notification channels etc.)"
    echo "  2. Test:            patchmox check"
    echo "  3. Enable schedule: systemctl enable --now patchmox.timer"
fi

exit 0
