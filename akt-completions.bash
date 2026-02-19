# Bash completions for akt (Akamai Toolkit)
# Source this file: source /path/to/akt-completions.bash
# Or add to ~/.bashrc / ~/.zshrc

_akt_completions() {
    local cur prev commands
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    commands="diag headers dns edge-ip decode trace estats qgrep crawly cracker purge gtm property troubleshoot help"

    case "$prev" in
        akt)
            COMPREPLY=($(compgen -W "$commands" -- "$cur"))
            return 0
            ;;
        decode|dec)
            COMPREPLY=($(compgen -W "cache-key x-cache ref" -- "$cur"))
            return 0
            ;;
        --network)
            COMPREPLY=($(compgen -W "essl fflow flash mega sqa ighost" -- "$cur"))
            return 0
            ;;
        --type)
            COMPREPLY=($(compgen -W "errors hits edge midgress origin" -- "$cur"))
            return 0
            ;;
        --section)
            # Try to parse edgerc sections
            if [[ -f "$HOME/.edgerc" ]]; then
                local sections
                sections=$(grep '^\[' "$HOME/.edgerc" | tr -d '[]' | tr '\n' ' ')
                COMPREPLY=($(compgen -W "$sections" -- "$cur"))
            fi
            return 0
            ;;
        estats|es)
            COMPREPLY=($(compgen -W "--network --type" -- "$cur"))
            return 0
            ;;
        qgrep|qg)
            COMPREPLY=($(compgen -W "--hours --ghost-ip --country" -- "$cur"))
            return 0
            ;;
        purge)
            COMPREPLY=($(compgen -W "--staging --production" -- "$cur"))
            return 0
            ;;
        cracker|crack|ck)
            COMPREPLY=($(compgen -W "--staging" -- "$cur"))
            return 0
            ;;
    esac

    if [[ "$cur" == -* ]]; then
        COMPREPLY=($(compgen -W "--section --help --version --json" -- "$cur"))
        return 0
    fi
}

complete -F _akt_completions akt
