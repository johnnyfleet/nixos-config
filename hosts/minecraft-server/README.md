# minecraft-server (Oracle Cloud, aarch64)

NixOS replacement for the Ubuntu 22.04 box (`ubuntu@minecraft-server`).

| Ubuntu box                                         | Here                                                         |
| -------------------------------------------------- | ------------------------------------------------------------ |
| docker-compose `itzg/minecraft-bedrock-server`     | `modules.minecraftBedrock` (podman, host networking)         |
| `~/minecraft-server/minecraft_data`                | `/var/lib/minecraft-bedrock`                                 |
| ufw: allow tailscale0, deny 22/tcp, allow 19132/udp | nftables firewall: tailscale0 trusted, public 19132/udp only |
| cron 00:00 restic container → R2, healthchecks.io  | `services.restic.backups.minecraft` timer + ExecStopPost ping |
| fail2ban sshd jail                                 | `services.fail2ban`                                          |
| `ubuntu` user, NOPASSWD sudo                       | `john` (github keys), NOPASSWD sudo                          |

## Test locally

```bash
nix build .#nixosConfigurations.minecraft-server.config.system.build.vm
./result/bin/run-minecraft-server-vm          # serial console in the terminal; Ctrl-a x to quit
ssh -p 2222 john@localhost
# Bedrock client -> Add server -> 127.0.0.1 : 19132
sudo systemctl start restic-backups-minecraft  # backs up to /var/backup/restic-minecraft
```

The VM sets `minecraftServer.testVm = true`: no sops, local restic repo, SSH open on
eth0 for port-forwarding, x86_64 instead of aarch64. Disk state is in `./minecraft-server.qcow2`
(delete it to start fresh). Tailscale is enabled but not logged in - `sudo tailscale up`
would register a *second* `minecraft-server` node, so use an ephemeral key if you try it.

To test with the real world, copy it in:
`rsync -a ubuntu@minecraft-server:minecraft-server/minecraft_data/worlds/ ...` then
`scp -P 2222` into `/var/lib/minecraft-bedrock/worlds/` and restart `podman-minecraft-bedrock`.

## Secrets (before deploying for real)

1. Before installing, run `sops-new-host minecraft-server` (see `docs/sops.md`) and pass the
   printed directory to nixos-anywhere with `--extra-files`.
2. `sops secrets/minecraft-server.yaml` and replace the `REPLACE_ME` placeholders
   (values from `~/.restic.env` on the Ubuntu box):

```yaml
minecraft-server:
  restic-repository: s3:https://<account>.r2.cloudflarestorage.com/<bucket>
  restic-password: <RESTIC_PASSWORD>
  restic-env: |
    AWS_ACCESS_KEY_ID=...
    AWS_SECRET_ACCESS_KEY=...
    HEALTHCHECK_URL=https://hc-ping.com/<uuid>
  tailscale-authkey: tskey-auth-...   # one-off, for first login
```

## Migration outline

1. Final backup on Ubuntu, stop the container.
2. Install: `nixos-anywhere --flake .#minecraft-server --generate-hardware-config nixos-generate-config ./hosts/minecraft-server/hardware-configuration.nix ubuntu@<public-ip>`
   (needs public SSH temporarily, or run it over tailscale before ufw changes take effect).
   Add `--extra-files <dir from sops-new-host>` so the first boot can decrypt its secrets.
3. Restore. Old snapshots hold the whole `~/minecraft-server` dir at `/data` (container path):
   ```bash
   restic restore latest --host minecraft-server --path /data --target /tmp/r
   rsync -a /tmp/r/data/minecraft_data/ /var/lib/minecraft-bedrock/
   cp /tmp/r/data/extra/allowlist.json /var/lib/minecraft-bedrock/allowlist.json  # was bind-mounted over the stale one
   systemctl restart podman-minecraft-bedrock
   ```
   New snapshots use path `/var/lib/minecraft-bedrock`; old `/data` ones are still pruned by the same policy.
4. Update the `soc` alias in `home/john/core/zsh/default.nix` to `ssh john@minecraft-server`.

Later deploys (builds on the server itself, avoiding aarch64 cross-builds on the laptop):
`nixos-rebuild switch --flake .#minecraft-server --target-host john@minecraft-server --build-host john@minecraft-server --sudo`
