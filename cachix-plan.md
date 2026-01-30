# Plan: Self-Hosted Nix Binary Cache with Attic

## Progress Checklist

Use this to track progress and resume in a new session.

### Unraid Setup (Prerequisites)
- [x] Created `/mnt/user/appdata/attic/server.toml` config file
- [x] **Fixed:** Added trailing slash to `api-endpoint` (CRITICAL)
- [x] Set up PostgreSQL container (`attic-postgres`)
- [x] Set up Attic container with `--config /attic/server.toml` in Post Arguments
- [x] Verified Attic is accessible via Tailscale at `http://big-john.zapus-interval.ts.net:8085`

### Attic Configuration
- [x] Created admin token (with `--configure-cache-retention "*"`)
- [x] Created cache: `nixos-config`
- [x] Made cache public: `attic cache configure local:nixos-config --public`
- [x] Verified cache public key: `nixos-config:rjFIX22X+ouzAFC483PIwXqF1/2XQ059C+QSoUq+XWo=`
- [x] Created CI push token for GitHub Actions
- [x] Pushed current system to cache (566 paths cached, 2858 in upstream)

### Tailscale & GitHub Secrets
- [x] Created Tailscale OAuth client (Settings > Trust credentials > OAuth clients)
- [x] Added GitHub repository secrets:
  - [x] `TS_OAUTH_CLIENT_ID`
  - [x] `TS_OAUTH_SECRET`
  - [x] `ATTIC_SERVER` = `http://big-john.zapus-interval.ts.net:8085`
  - [x] `ATTIC_TOKEN`

### NixOS Configuration
- [x] Updated `hosts/common/core/configuration.nix` with Attic substituters
- [x] **Fixed:** Deleted stale `~/.config/nix/nix.conf` that had `localhost:8080/hello`
- [x] Verified `/etc/nix/nix.conf` has correct substituter URL with `/nixos-config` path

### GitHub Workflows
- [x] Create `.github/workflows/build-and-cache.yml`
- [x] Create `.github/workflows/update-flake.yml`
- [x] **Fixed:** Added `jlumbroso/free-disk-space` action (runner was running out of disk)
- [x] **Fixed:** Changed `nix-env -iA` to `nix profile install` for attic-client
- [x] **Fixed:** Push full closure with `$(nix path-info --recursive ./result)` to include substituted paths
- [x] Push to main and verify CI connects to Tailscale
- [x] Verify CI builds and pushes to Attic cache

### Final Verification
- [x] Tested scheduled flake update workflow - working
- [x] Verified packages download from Attic cache on local rebuild
- [ ] Verify fallback works when off Tailscale (optional - test when away from home)

---

### Session Resume Context

**Current state:** ✅ SETUP COMPLETE! Everything is working end-to-end.

**What's working:**
- Attic binary cache running on Unraid (via Docker)
- NixOS configured to fetch from Attic with fallback to cache.nixos.org
- GitHub Actions builds all configs on push to main and uploads to Attic
- Weekly flake updates run automatically (Thursday 01:00 NZST)
- Full closure pushed to cache (including substituted paths)

**Key details:**
- Attic URL: `http://big-john.zapus-interval.ts.net:8085`
- Cache name: `nixos-config`
- Public key: `nixos-config:rjFIX22X+ouzAFC483PIwXqF1/2XQ059C+QSoUq+XWo=`
- NixOS config file: `hosts/common/core/configuration.nix`
- Workflow files: `.github/workflows/build-and-cache.yml` and `.github/workflows/update-flake.yml`
- Weekly schedule: Wednesday 13:00 UTC (Thursday 01:00 NZST)

**Optional remaining task:** Verify fallback works when off Tailscale (test when away from home)

---

## Overview

Set up a self-hosted Nix binary cache using Attic on your Unraid NAS, accessible via Tailscale, with GitHub Actions for automated builds and weekly flake updates.

**Architecture:**
- Attic server running on Unraid NAS (Docker)
- GitHub Actions connects via Tailscale to push builds
- NixOS machines pull from Attic (with fallback to cache.nixos.org)

---

## Prerequisites (Manual Steps on Unraid)

### 1. Create Configuration File

Before adding containers, create the Attic config file:

```bash
mkdir -p /mnt/user/appdata/attic
```

Create `/mnt/user/appdata/attic/server.toml`:
```toml
listen = "[::]:8080"
api-endpoint = "http://<your-nas-tailscale-hostname>:<port>/"

[database]
url = "postgres://attic:YOUR_DB_PASSWORD@attic-postgres:5432/attic"

[storage]
type = "local"
path = "/attic/storage"

[compression]
type = "zstd"

[garbage-collection]
interval = "12 hours"
default-retention-period = "6 months"

[chunking]
nar-size-threshold = 65536
min-size = 16384
avg-size = 65536
max-size = 262144
```

**CRITICAL:** The `api-endpoint` MUST have a trailing slash! Without it, Attic constructs incorrect URLs (e.g., `...8085nixos-config` instead of `...8085/nixos-config`).

Generate the token secret (run on Unraid terminal):
```bash
openssl rand 64 | base64 -w0
# Save this output for the ATTIC_SERVER_TOKEN_HS256_SECRET_BASE64 variable
```

---

### 2. Add PostgreSQL Container (Unraid UI)

Go to **Docker > Add Container** and enter:

| Field | Value |
|-------|-------|
| Name | `attic-postgres` |
| Repository | `postgres:17-alpine` |
| Network Type | `bridge` (or your custom network) |

**Environment Variables** (click "Add another Path, Port, Variable..."):

| Type | Name | Value |
|------|------|-------|
| Variable | `POSTGRES_DB` | `attic` |
| Variable | `POSTGRES_USER` | `attic` |
| Variable | `POSTGRES_PASSWORD` | `<your-strong-password>` |

**Volumes**:

| Type | Container Path | Host Path |
|------|----------------|-----------|
| Path | `/var/lib/postgresql/data` | `/mnt/user/appdata/attic-postgres/` |

Click **Apply**.

---

### 3. Add Attic Container (Unraid UI)

Go to **Docker > Add Container** and enter:

| Field | Value |
|-------|-------|
| Name | `attic` |
| Repository | `ghcr.io/zhaofengli/attic:latest` |
| Network Type | `bridge` (same as postgres) |

**Port Mappings**:

| Type | Container Port | Host Port |
|------|----------------|-----------|
| Port | `8080` | `<your-chosen-port>` |

**Note:** Container always listens on 8080 internally. Map to any host port you prefer (e.g., 8085).

**Environment Variables**:

| Type | Name | Value |
|------|------|-------|
| Variable | `ATTIC_SERVER_TOKEN_HS256_SECRET_BASE64` | `<your-generated-secret>` |

**Volumes**:

| Type | Container Path | Host Path | Mode |
|------|----------------|-----------|------|
| Path | `/attic/server.toml` | `/mnt/user/appdata/attic/server.toml` | Read Only |
| Path | `/attic/storage` | `/mnt/user/appdata/attic/storage/` | Read/Write |

**Extra Parameters**:
```
--link attic-postgres:attic-postgres
```

**Post Arguments** (REQUIRED - tells Attic where to find config):
```
--config /attic/server.toml
```

Click **Apply**.

**Note:** Without the `--config` flag, Attic ignores the mounted server.toml and creates a default SQLite config at `/var/empty/.config/attic/server.toml`.

---

### 4. Tailscale Network Access

Since you have the Tailscale plugin installed, Attic will be accessible at:
- `http://<your-nas-tailscale-hostname>:<port>`

Find your NAS's Tailscale hostname/IP in the Tailscale admin console.

Update `server.toml` with your actual Tailscale hostname before starting the containers:
```toml
api-endpoint = "http://<your-nas-tailscale-hostname>:<port>/"
```

**CRITICAL:** Don't forget the trailing slash!

### 5. Create Attic Admin Token

After starting both containers, create an admin token:
```bash
docker exec -it attic atticadm make-token \
  --sub "admin" \
  --validity "10y" \
  --pull "*" --push "*" \
  --create-cache "*" --configure-cache "*" \
  --configure-cache-retention "*" \
  --destroy-cache "*" --delete "*" \
  -f /attic/server.toml
```

**Note:** The `--configure-cache-retention` flag is required to modify cache settings like public access.

### 6. Create the Cache

Use the attic CLI from any machine on your Tailnet:
```bash
# Install attic CLI
nix-shell -p attic-client

# Login to your server
attic login local http://<your-nas-tailscale-hostname>:<port> <admin-token>

# Create the cache (note the public key output!)
attic cache create local:nixos-config

# Make the cache publicly readable (still protected by Tailscale)
attic cache configure local:nixos-config --public
```

**Save the public key** - you'll need it for NixOS configuration.

**Notes:**
- The `--public` flag allows anonymous reads so Nix can fetch without authentication. Since Attic is only accessible via Tailscale, this is still secure.
- Attic serves caches at `http://<server>:<port>/<cache-name>`. The cache name must be included in the URL when configuring Nix substituters.

### 7. Create CI Push Token

Create a token with limited permissions for CI:
```bash
docker exec -it attic atticadm make-token \
  --sub "github-ci" \
  --validity "1y" \
  --pull "nixos-config" --push "nixos-config" \
  -f /attic/server.toml
```

### 8. Create Tailscale OAuth Client

1. Go to Tailscale Admin Console > Settings > Trust credentials > OAuth clients
2. Create new OAuth client with scope: `auth_keys` (writable)
3. Create a tag (e.g., `tag:ci`) in your ACL policy
4. Save the client ID and secret

### 9. Add GitHub Repository Secrets

Go to your repo's **Settings > Secrets and variables > Actions > Repository secrets** and add:

- `TS_OAUTH_CLIENT_ID` - Tailscale OAuth client ID
- `TS_OAUTH_SECRET` - Tailscale OAuth client secret
- `ATTIC_SERVER` - Your Attic server base URL without cache name (e.g., `http://big-john.zapus-interval.ts.net:8085`)
- `ATTIC_TOKEN` - CI push token from step 7

---

## Implementation

### 1. Update NixOS Configuration

**File:** `hosts/common/core/configuration.nix`

Add your self-hosted cache with fallback:

```nix
nix.settings = {
  experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Binary caches - tries in order, falls back if unavailable
  substituters = [
    "http://<your-nas-tailscale-hostname>:<port>/<cache-name>"  # Self-hosted Attic (via Tailscale)
    "https://cache.nixos.org/"                                   # Fallback
  ];

  trusted-public-keys = [
    "<cache-name>:<PUBLIC-KEY-FROM-ATTIC>="
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
  ];

  # Don't fail if self-hosted cache is unreachable
  fallback = true;
  connect-timeout = 5;
};
```

**Important:** The substituter URL must include the cache name in the path (e.g., `/nixos-config`).

### 2. Create Build and Cache Workflow

**File:** `.github/workflows/build-and-cache.yml`

```yaml
name: Build and Cache NixOS Configurations

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-latest
    strategy:
      fail-fast: false
      matrix:
        config: [john-laptop, john-sony-laptop, vm]

    steps:
      - uses: actions/checkout@v4

      - name: Connect to Tailscale
        uses: tailscale/github-action@v4
        with:
          oauth-client-id: ${{ secrets.TS_OAUTH_CLIENT_ID }}
          oauth-secret: ${{ secrets.TS_OAUTH_SECRET }}
          tags: tag:ci

      - name: Install Nix
        uses: DeterminateSystems/nix-installer-action@main
        with:
          extra-conf: |
            accept-flake-config = true

      - name: Setup Attic
        run: |
          nix profile install nixpkgs#attic-client
          attic login ci "${{ secrets.ATTIC_SERVER }}" "${{ secrets.ATTIC_TOKEN }}"
          attic use nixos-config

      - name: Build NixOS configuration
        run: |
          nix build .#nixosConfigurations.${{ matrix.config }}.config.system.build.toplevel \
            --print-build-logs --show-trace

      - name: Push to Attic
        if: github.event_name == 'push' && github.ref == 'refs/heads/main'
        run: |
          attic push nixos-config ./result

      - name: Run flake check
        if: matrix.config == 'john-laptop'
        run: nix flake check --print-build-logs

  build-summary:
    runs-on: ubuntu-latest
    needs: build
    if: always()
    steps:
      - name: Check results
        run: |
          if [ "${{ needs.build.result }}" == "success" ]; then
            echo "All builds completed successfully!"
          else
            exit 1
          fi
```

### 3. Create Weekly Flake Update Workflow

**File:** `.github/workflows/update-flake.yml`

```yaml
name: Update Flake Inputs

on:
  schedule:
    - cron: '0 13 * * 3'  # Wednesday 13:00 UTC = Thursday 01:00 NZST
  workflow_dispatch:

permissions:
  contents: write

jobs:
  update:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          token: ${{ secrets.GITHUB_TOKEN }}

      - name: Connect to Tailscale
        uses: tailscale/github-action@v4
        with:
          oauth-client-id: ${{ secrets.TS_OAUTH_CLIENT_ID }}
          oauth-secret: ${{ secrets.TS_OAUTH_SECRET }}
          tags: tag:ci

      - name: Install Nix
        uses: DeterminateSystems/nix-installer-action@main

      - name: Setup Attic
        run: |
          nix profile install nixpkgs#attic-client
          attic login ci "${{ secrets.ATTIC_SERVER }}" "${{ secrets.ATTIC_TOKEN }}"
          attic use nixos-config

      - name: Update flake inputs
        run: nix flake update

      - name: Check for changes
        id: check
        run: |
          if git diff --quiet flake.lock; then
            echo "changes=false" >> $GITHUB_OUTPUT
          else
            echo "changes=true" >> $GITHUB_OUTPUT
          fi

      - name: Build all configurations
        if: steps.check.outputs.changes == 'true'
        run: |
          nix build .#nixosConfigurations.john-laptop.config.system.build.toplevel --print-build-logs
          nix build .#nixosConfigurations.john-sony-laptop.config.system.build.toplevel --print-build-logs
          nix build .#nixosConfigurations.vm.config.system.build.toplevel --print-build-logs

      - name: Push to Attic
        if: steps.check.outputs.changes == 'true'
        run: |
          attic push nixos-config ./result

      - name: Commit and push
        if: steps.check.outputs.changes == 'true'
        run: |
          git config --local user.email "github-actions[bot]@users.noreply.github.com"
          git config --local user.name "github-actions[bot]"
          git add flake.lock
          git commit -m "chore: regular updates"
          git push
```

---

## Files to Create/Modify

| File | Action |
|------|--------|
| `hosts/common/core/configuration.nix` | Modify - Add Attic substituters with fallback |
| `.github/workflows/build-and-cache.yml` | Create - Build and push to Attic |
| `.github/workflows/update-flake.yml` | Create - Weekly flake updates |

---

## Verification

1. **Test Attic connectivity:**
   ```bash
   # Verify cache is publicly readable (should return cache info, not 401)
   curl http://<your-nas-tailscale-hostname>:<port>/<cache-name>/nix-cache-info
   ```

2. **Test Attic CLI:**
   ```bash
   nix-shell -p attic-client
   attic login local http://<your-nas-tailscale-hostname>:<port> <your-token>
   attic cache info local:nixos-config

   # Verify Binary Cache Endpoint has correct URL format with slash
   # Should show: http://hostname:port/cache-name (NOT hostname:portcache-name)
   ```

3. **Push to cache:**
   ```bash
   attic push nixos-config /run/current-system
   ```

4. **Test NixOS rebuild:**
   ```bash
   sudo nixos-rebuild switch --flake .#john-laptop -v 2>&1 | grep -i "big-john\|copying\|substitut"
   ```

5. **Test CI:**
   - Push to main, check GitHub Actions
   - Verify artifacts appear in Attic storage folder on Unraid

---

## How Fallback Works

Nix tries substituters in order. If your Attic server is unreachable (not on Tailscale), it:
1. Times out after `connect-timeout` seconds
2. Falls back to cache.nixos.org
3. Builds from source if not in any cache

This means your laptop works normally even when away from home.

---

## Troubleshooting

### Attic ignores server.toml, creates default SQLite config
**Symptom:** Logs show "A simple setup using SQLite and local storage has been configured for you"

**Fix:** Add `--config /attic/server.toml` to Post Arguments in Unraid container settings.

### Binary Cache Endpoint URL is malformed (missing slash)
**Symptom:** `attic cache info` shows URL like `...8085nixos-config` instead of `...8085/nixos-config`

**Fix:** Add trailing slash to `api-endpoint` in server.toml: `api-endpoint = "http://hostname:port/"`

### Permission denied when configuring cache
**Symptom:** `attic cache configure` returns "User does not have permission"

**Fix:** Ensure admin token includes `--configure-cache-retention "*"` flag.

### Nix tries to connect to wrong substituter (localhost:8080/hello)
**Symptom:** Build errors reference `localhost:8080/hello` instead of your Attic URL

**Cause:** Running `attic use` creates a user-level `~/.config/nix/nix.conf` that overrides system config.

**Fix:** Delete stale user config:
```bash
rm ~/.config/nix/nix.conf ~/.config/nix/netrc
```

### Cache returns 401 Unauthorized
**Symptom:** `curl .../nix-cache-info` returns 401

**Fix:** Make cache publicly readable:
```bash
attic cache configure local:nixos-config --public
```

---

## Sources

- [Attic GitHub](https://github.com/zhaofengli/attic)
- [Attic Docker Compose Guide](https://nexveridian.com/blog/attic-compose/)
- [Tailscale GitHub Action](https://tailscale.com/kb/1276/tailscale-github-action)
