#!/bin/sh
set -e

if [ -d /run/systemd/system ]; then
    systemctl daemon-reload >/dev/null 2>&1 || true
fi

if [ "$1" = "purge" ]; then
    rm -rf /var/lib/patchmox /var/log/patchmox /etc/patchmox
    # Rendered banners (update-<vmid>.svg). Banner <img> tags in VM
    # descriptions are not touched here.
    find /usr/share/pve-manager/images -maxdepth 1 -type f \
        -regex '.*/update-[0-9]+\.svg' -delete 2>/dev/null || true
fi

exit 0
