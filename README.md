# akt - Akamai Toolkit

Unified CLI for Akamai telemetry, diagnostics, and troubleshooting. Combines internal tools (eSTATS, QGrep, ART, Crawly, Cracker) with external tools (Akamai CLI, APIs, curl diagnostics) into a single command.

## Install

```bash
# Symlink to PATH
ln -s /Users/bapley/project-akamaitools/akt /usr/local/bin/akt

# Enable tab completions (add to ~/.zshrc or ~/.bashrc)
source /Users/bapley/project-akamaitools/akt-completions.bash
```

### Requirements

- bash 4+
- curl, dig, openssl (standard macOS)
- python3 (for URL encoding and JSON parsing)
- [Akamai CLI](https://techdocs.akamai.com/developer/docs/about-clis) (optional, for purge/gtm/property commands)
- `~/.edgerc` configured with API credentials

## Quick Start

```bash
# Full diagnostic of any URL
akt diag https://example.com

# DNS resolution chain
akt dns www.example.com

# Fetch and display Akamai debug headers
akt headers https://example.com

# Decode a cache key
akt decode cache-key "S/D/12345/67890/000/origin.example.com/path"

# Interactive troubleshooting wizard
akt troubleshoot
```

## Commands

### Diagnostics

| Command | Description |
|---------|-------------|
| `akt diag <url>` | Full diagnostic: DNS chain, debug headers, timing breakdown, cache analysis, and suggested next steps |
| `akt headers <url>` | Fetch response with all Akamai pragma debug headers, color-coded output |
| `akt dns <hostname>` | Full CNAME resolution chain with Akamai hostname identification and TTLs |
| `akt edge-ip <hostname>` | Resolve to edge server IP with reverse DNS confirmation |
| `akt decode <type> <value>` | Decode Akamai headers: `cache-key`, `x-cache`, `ref` (reference numbers) |

### Internal Tools (opens in browser)

| Command | Description |
|---------|-------------|
| `akt trace <url>` | Fetch debug headers, copy to clipboard, open ART for request tracing |
| `akt estats [cpcode\|url]` | Open eSTATS for edge error/hit statistics |
| `akt qgrep <cpcode>` | Open QGrep for DDC log archive retrieval |
| `akt crawly <ref#\|headers>` | Open Crawly with pre-filled input for log crawling |
| `akt cracker <url>` | Open Cracker for comprehensive URL analysis |

### Akamai CLI Wrappers

| Command | Description |
|---------|-------------|
| `akt purge <url\|cpcode>` | Invalidate cached content (with confirmation prompt) |
| `akt gtm [domain] [property]` | List GTM domains, properties, and datacenter status |
| `akt property <name>` | Property Manager search and lookup |

### Workflows

| Command | Description |
|---------|-------------|
| `akt troubleshoot` | Interactive wizard for: slow responses, errors, cache issues, DNS, origin, go-live, SSL |

## Usage Examples

### Trace a request end-to-end

```bash
# 1. Run full diagnostic
akt diag https://www.example.com

# 2. Open the request trace in ART
akt trace https://www.example.com

# 3. Crawl logs for a reference number from an error page
akt crawly "#18.a4a50517.1490847914.52e002"

# 4. Check edge statistics for the CP code
akt estats 339087
```

### Decode response headers

```bash
# Decode a cache key
akt decode cache-key "S/D/339087/1959762/000/origin.example.com/path?query vcd=840"
# → CP Code: 339087, Origin: origin.example.com, VCD: 840

# Decode X-Cache status
akt decode x-cache "TCP_MISS from a23-209-83-97.deploy.akamaitechnologies.com (AkamaiGHost/22.4.2) (-)"
# → Status: MISS, Ghost IP: 23.209.83.97, Version: 22.4.2

# Decode an error reference number
akt decode ref "#18.a4a50517.1490847914.52e002"
# → Error Type: 18, Timestamp: 2017-03-30, Ghost: a4a50517
```

### Cache purge

```bash
# Purge by URL
akt purge https://www.example.com/page.html

# Purge by CP code on staging
akt purge 339087 --staging
```

### eSTATS with options

```bash
# Check errors on FreeFlow network
akt estats 339087 --network fflow --type errors

# Check edge hits on ESSL
akt estats 339087 --network essl --type hits
```

## Global Options

| Flag | Description |
|------|-------------|
| `--section <name>` | edgerc section to use (default: `default`) |
| `--help`, `-h` | Show help |
| `--version`, `-v` | Show version |

## Configuration

### ~/.edgerc

Standard Akamai API credentials file. Used by `purge`, `gtm`, and `property` commands.

```ini
[default]
client_secret = xxx
host = xxx
access_token = xxx
client_token = xxx
```

### ~/.aktrc

Optional user preferences (sourced as bash):

```bash
# Default eSTATS network
AKT_ESTATS_NETWORK=essl

# Default eSTATS type
AKT_ESTATS_TYPE=errors

# Override edgerc section
AKT_SECTION=default
```

## Internal Tool Reference

| Tool | URL | Purpose |
|------|-----|---------|
| eSTATS | tools.gss.akamai.com/estats | Real-time edge error/hit statistics by CP code, IP, region |
| QGrep | qssi.akamai.com | DDC log archive retrieval (14-day retention, ~12 min retrieval) |
| ART | tools.gss.akamai.com/art/ | Request tracing - paste response headers to see full edge-to-origin path |
| Crawly | crawly-aps.akamai.com | Recursive log crawler - trace from ref#, headers, or log lines |
| Cracker | cracker-aps.akamai.com | Universal URL cracker - headers, DNS, metadata, cache, SSL, diagnostics |

## Akamai Header Quick Reference

| Header | Meaning |
|--------|---------|
| `X-Cache` | Ghost server IP + cache status (TCP_HIT, TCP_MISS, TCP_REFRESH_HIT, TCP_DENIED) |
| `X-Cache-Key` | `S\|L / D\|H / cpcode / serial / hostname / path` — full cache key |
| `X-Cache-Remote` | Parent/midgress cache status |
| `X-True-Cache-Key` | Cache key after query string normalization |
| `X-Check-Cacheable` | YES/NO — whether the object is configured as cacheable |
| `X-Akamai-Request-ID` | Unique request ID for log correlation across tools |
| `X-Serial` | Serial number (often matches CP code) |

## Command Aliases

Most commands have short aliases:

| Full | Aliases |
|------|---------|
| `diag` | `diagnose`, `diagnostic` |
| `headers` | `hdr`, `head` |
| `decode` | `dec` |
| `trace` | `art` |
| `estats` | `es` |
| `qgrep` | `qg` |
| `crawly` | `crawl`, `cr` |
| `cracker` | `crack`, `ck` |
| `property` | `prop`, `pm` |
| `troubleshoot` | `ts`, `wizard` |
| `edge-ip` | `edgeip`, `eip` |

## Project Structure

```
project-akamaitools/
├── akt                      # Main CLI script
├── akt-completions.bash     # Bash/zsh tab completions
├── docs/                    # Internal tool documentation (PDFs)
└── README.md
```
