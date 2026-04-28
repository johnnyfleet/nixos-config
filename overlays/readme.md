# Overlays
This folder holds the overlays I have created when building my machines. 

Most of the overlays are due to a build failing due to a flaky test or hash mismatch where upstream isn't up to date yet. 

Given that they tend to be short lived, days or at most weeks. 


## Check if overlay is no longer required
To check and clean up when no longer required the fastest way is to test each package directly from nixpkgs without your overlays applied:

e.g.

```bash
# Test if tailscale builds without disabling tests
nix build nixpkgs#tailscale

# Test if easytag builds without the id3lib fix
nix build nixpkgs#easytag

# Test if the claude-code extension hash is fixed
nix build nixpkgs#vscode-extensions.anthropic.claude-code
```

These use your flake's pinned nixpkgs input directly — no overlays applied. If the build succeeds, the overlay is no longer needed.

### Check upstream
For test-related overlays like your tailscale one, you can also check if the upstream issue was resolved by looking at recent commits:

``` bash
gh search commits --repo NixOS/nixpkgs "tailscale" --order desc --limit 5
```