# bash completion for patchmox
# Installed as /usr/share/bash-completion/completions/patchmox (Debian package)
# or /etc/bash_completion.d/patchmox (install.sh).

# VM IDs (QEMU only) from the cluster-wide VM list maintained by pmxcfs.
_patchmox_vmids() {
    local vmlist="${PATCHMOX_VMLIST:-/etc/pve/.vmlist}"
    [[ -r "$vmlist" ]] || return 0
    if command -v jq >/dev/null 2>&1; then
        jq -r '.ids // {} | to_entries[] | select(.value.type == "qemu") | .key' "$vmlist" 2>/dev/null
    else
        grep -oE '"[0-9]+": *\{[^}]*"type": *"qemu"' "$vmlist" | grep -oE '^"[0-9]+"' | tr -d '"'
    fi
}

_patchmox() {
    local cur prev cmd
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    cmd="${COMP_WORDS[1]:-}"

    local commands="check notify worker apply policy state cleanup version help"

    if [[ $COMP_CWORD -eq 1 ]]; then
        COMPREPLY=( $(compgen -W "$commands" -- "$cur") )
        return 0
    fi

    # Values for options
    case "$prev" in
        --vmid)
            COMPREPLY=( $(compgen -W "$(_patchmox_vmids)" -- "$cur") )
            return 0
            ;;
        --channel)
            COMPREPLY=( $(compgen -W "smtp webhook" -- "$cur") )
            return 0
            ;;
        --component)
            COMPREPLY=( $(compgen -W "virtio qemu-ga" -- "$cur") )
            return 0
            ;;
        --max-jobs)
            return 0
            ;;
    esac

    local opts=""
    case "$cmd" in
        check)   opts="--vmid --force-refresh" ;;
        notify)  opts="--test --channel" ;;
        worker)  opts="--once --max-jobs --daemon" ;;
        apply)   opts="--vmid --component" ;;
        policy)  opts="--dry-run --vmid" ;;
        state)   opts="--vmid" ;;
        cleanup) opts="--dry-run --vmid" ;;
        *)       return 0 ;;
    esac

    # `patchmox check` also accepts VM IDs as plain arguments
    if [[ "$cmd" == check && "$cur" != -* ]]; then
        COMPREPLY=( $(compgen -W "$(_patchmox_vmids)" -- "$cur") )
        return 0
    fi

    COMPREPLY=( $(compgen -W "$opts" -- "$cur") )
}

complete -F _patchmox patchmox
