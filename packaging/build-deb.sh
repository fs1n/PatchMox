#!/usr/bin/env bash
#
# Builds the PatchMox .deb with nfpm into dist/.
# Usage: packaging/build-deb.sh            # version from `git describe`
#        VERSION=1.2.3 packaging/build-deb.sh

set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if ! command -v nfpm >/dev/null 2>&1; then
    echo "nfpm not found — see https://nfpm.goreleaser.com/install/" >&2
    exit 1
fi

if [[ -z "${VERSION:-}" ]]; then
    VERSION="$(git describe --tags --always 2>/dev/null || echo 0.0.0)"
fi
export VERSION="${VERSION#v}"

# Version shipped in the package (read by `patchmox version`)
mkdir -p build dist
printf '%s\n' "$VERSION" > build/VERSION

nfpm package --config packaging/nfpm.yaml --packager deb --target dist/
