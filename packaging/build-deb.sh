#!/usr/bin/env bash
#
# Builds the PatchMox .deb with nfpm into dist/.
# Usage: packaging/build-deb.sh            # version from `git describe`
#        VERSION=1.2.3 packaging/build-deb.sh

set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if ! command -v nfpm >/dev/null 2>&1; then
    echo "nfpm not found - see https://nfpm.goreleaser.com/install/" >&2
    exit 1
fi

if [[ -z "${VERSION:-}" ]]; then
    # Must be a valid Debian version that sorts correctly:
    #   tag v1.2.3            -> 1.2.3
    #   3 commits after it    -> 1.2.3+git3.gabc1234   (newer than 1.2.3)
    #   no tag yet            -> 0.0.0+git.abc1234      (not a bare hash)
    if desc="$(git describe --tags --match 'v[0-9]*' 2>/dev/null)"; then
        desc="${desc#v}"
        if [[ "$desc" =~ ^(.+)-([0-9]+)-(g[0-9a-f]+)$ ]]; then
            VERSION="${BASH_REMATCH[1]}+git${BASH_REMATCH[2]}.${BASH_REMATCH[3]}"
        else
            VERSION="$desc"
        fi
    else
        VERSION="0.0.0+git.$(git rev-parse --short HEAD 2>/dev/null || echo unknown)"
    fi
fi
export VERSION="${VERSION#v}"

# Version shipped in the package (read by `patchmox version`)
mkdir -p build dist
printf '%s\n' "$VERSION" > build/VERSION

nfpm package --config packaging/nfpm.yaml --packager deb --target dist/
