#!/bin/sh
set -e

if [ "$1" = "remove" ] && [ -d /run/systemd/system ]; then
    systemctl disable --now patchmox.timer >/dev/null 2>&1 || true
    systemctl stop patchmox.service >/dev/null 2>&1 || true
fi

exit 0
