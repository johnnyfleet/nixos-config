---
title: Self-Hosted Nix Binary Cache with Attic
created: 2025-01-24
status: complete
tags:
  - nixos
  - homelab
  - ci-cd
  - caching
---

# Self-Hosted Nix Binary Cache with Attic

## Goal

Speed up NixOS rebuild times by pre-building configurations in CI and caching them in a self-hosted binary cache. When updating the local system, packages are fetched from the cache instead of being built from source.

## Approach

Rather than using a paid service like [Cachix](https://www.cachix.org/), we self-host [Attic](https://github.com/zhaofengli/attic) on an Unraid NAS. The cache is accessible via [Tailscale](https://tailscale.com/) VPN, providing secure access without exposing it to the internet.

GitHub Actions connects to the Tailscale network, builds all NixOS configurations, and pushes the results to Attic. Local machines then fetch pre-built packages from the cache.

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│  GitHub Actions │────▶│  Attic Cache    │◀────│  NixOS Machine  │
│  (builds)       │     │  (Unraid NAS)   │     │  (fetches)      │
└─────────────────┘     └─────────────────┘     └─────────────────┘
         │                       │                       │
         └───────────────────────┴───────────────────────┘
                         Tailscale Network
```

## Key Components

### Attic Binary Cache Server

- **What**: Self-hosted Nix binary cache written in Rust
- **Where**: Docker container on Unraid NAS
- **Docs**: [Attic Documentation](https://docs.attic.rs/)
- **Source**: [GitHub - zhaofengli/attic](https://github.com/zhaofengli/attic)

### PostgreSQL Database

- **What**: Backend database for Attic metadata
- **Image**: `postgres:17-alpine`

### Tailscale VPN

- **What**: Secure mesh VPN connecting all devices
- **Why**: Allows GitHub Actions to reach the self-hosted cache
- **Docs**: [Tailscale Documentation](https://tailscale.com/kb/)
- **GitHub Action**: [tailscale/github-action](https://github.com/tailscale/github-action)

### GitHub Actions Workflows

| Workflow | Trigger | Purpose |
|----------|---------|---------|
| `build-and-cache.yml` | Push to main | Build all configs, push to Attic |
| `update-flake.yml` | Weekly (Thu 01:00 NZST) | Update flake inputs, rebuild, commit |

### NixOS Configuration

NixOS is configured to use the self-hosted cache as primary substituter with fallback to the official cache:

```nix
nix.settings = {
  substituters = [
    "http://<attic-server>/<cache-name>"
    "https://cache.nixos.org/"
  ];
  fallback = true;
  connect-timeout = 5;
};
```

## Setup Steps

### 1. Deploy Attic on Unraid

> [!important]
> The `api-endpoint` in server.toml **must** have a trailing slash!

1. Create config directory: `/mnt/user/appdata/attic/`
2. Create `server.toml` with database and storage configuration
3. Add PostgreSQL container via Unraid Docker UI
4. Add Attic container with `--config /attic/server.toml` in Post Arguments

**References:**
- [Attic Docker Compose Guide](https://nexveridian.com/blog/attic-compose/)
- [attic-compose GitHub](https://github.com/NexVeridian/attic-compose)

### 2. Configure Attic Cache

```bash
# Create admin token (include --configure-cache-retention for full permissions)
docker exec -it attic atticadm make-token \
  --sub "admin" --validity "10y" \
  --pull "*" --push "*" \
  --create-cache "*" --configure-cache "*" \
  --configure-cache-retention "*" \
  --destroy-cache "*" --delete "*" \
  -f /attic/server.toml

# Create cache and make it public
attic login local http://<server>:<port> <token>
attic cache create local:nixos-config
attic cache configure local:nixos-config --public
```

### 3. Setup Tailscale OAuth

1. Go to [Tailscale Admin Console](https://login.tailscale.com/admin/settings/oauth) > Settings > Trust credentials > OAuth clients
2. Create OAuth client with `auth_keys` scope
3. Create `tag:ci` in ACL policy

**References:**
- [Tailscale OAuth Clients](https://tailscale.com/kb/1215/oauth-clients/)
- [Tailscale GitHub Action](https://tailscale.com/kb/1276/tailscale-github-action/)

### 4. Configure GitHub Secrets

Add these repository secrets:
- `TS_OAUTH_CLIENT_ID` - Tailscale OAuth client ID
- `TS_OAUTH_SECRET` - Tailscale OAuth secret
- `ATTIC_SERVER` - Attic server URL (without cache name)
- `ATTIC_TOKEN` - CI push token

### 5. Create GitHub Workflows

> [!tip]
> Use `jlumbroso/free-disk-space` action to free ~30GB on runners before building.

Key workflow steps:
1. Free disk space
2. Connect to Tailscale
3. Install Nix via [DeterminateSystems/nix-installer-action](https://github.com/DeterminateSystems/nix-installer-action)
4. Setup Attic client
5. Build configurations
6. Push full closure: `attic push nixos-config $(nix path-info --recursive ./result)`

**References:**
- [free-disk-space action](https://github.com/jlumbroso/free-disk-space)
- [nix-installer-action](https://github.com/DeterminateSystems/nix-installer-action)

### 6. Update NixOS Configuration

Add Attic as a substituter in your NixOS config with fallback to cache.nixos.org.

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Attic ignores server.toml | Add `--config /attic/server.toml` to container Post Arguments |
| URL malformed (missing slash) | Add trailing slash to `api-endpoint` in server.toml |
| Permission denied configuring cache | Include `--configure-cache-retention "*"` in admin token |
| Nix uses wrong substituter | Delete stale `~/.config/nix/nix.conf` from previous `attic use` |
| Cache returns 401 | Run `attic cache configure local:<name> --public` |
| CI runs out of disk | Add `jlumbroso/free-disk-space` action before build |
| Packages still building locally | Push full closure with `$(nix path-info --recursive ./result)` |

## References

### Attic
- [Attic GitHub Repository](https://github.com/zhaofengli/attic)
- [Attic Documentation](https://docs.attic.rs/)
- [atticd CLI Reference](https://docs.attic.rs/reference/atticd-cli.html)
- [Attic Docker Compose Setup](https://nexveridian.com/blog/attic-compose/)

### Nix & NixOS
- [Nix Binary Cache](https://nixos.wiki/wiki/Binary_Cache)
- [NixOS Options: nix.settings](https://search.nixos.org/options?query=nix.settings)
- [Nix Manual - Substituters](https://nixos.org/manual/nix/stable/command-ref/conf-file.html#conf-substituters)

### GitHub Actions
- [DeterminateSystems/nix-installer-action](https://github.com/DeterminateSystems/nix-installer-action)
- [jlumbroso/free-disk-space](https://github.com/jlumbroso/free-disk-space)
- [GitHub Actions: Scheduled Events](https://docs.github.com/en/actions/using-workflows/events-that-trigger-workflows#schedule)

### Tailscale
- [Tailscale Documentation](https://tailscale.com/kb/)
- [Tailscale GitHub Action](https://github.com/tailscale/github-action)
- [Tailscale OAuth Clients](https://tailscale.com/kb/1215/oauth-clients/)

### Alternatives Considered
- [Cachix](https://www.cachix.org/) - Managed service (paid for private caches)
- [Harmonia](https://github.com/nix-community/harmonia) - Simpler self-hosted cache
- [nix-serve](https://github.com/edolstra/nix-serve) - Basic Nix store HTTP server
