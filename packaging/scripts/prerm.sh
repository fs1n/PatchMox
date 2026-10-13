#!/bin/sh
set -e

if [ "$1" = "remove" ]; then
    if [ -d /run/systemd/system ]; then
        systemctl disable --now patchmox.timer >/dev/null 2>&1 || true
        systemctl stop patchmox.service >/dev/null 2>&1 || true
    fi
    # Remove update banners from all VM descriptions. Never block removal.
    if [ -x /usr/bin/patchmox ]; then
        /usr/bin/patchmox cleanup || echo "patchmox: banner cleanup failed - remove the update banners from the VM descriptions manually" >&2
    fi
fi

exit 0
