# Task: rclone Google Drive mount with VFS cache (Home Manager)

## Context
- Repo: `johnnyfleet/nixos-config` — flake-based NixOS + Home Manager. I'm experimenting with the dendritic pattern; follow whatever module conventions the repo already uses.
- Target host: `john-laptop` (my user only). Keep it easy to enable on other hosts later.
- Goal: replace Insync on the laptop. Instead of syncing my whole Google Drive, mount it with rclone and a local VFS cache so files download only when opened.
- Google Drive also stays synced to Unraid separately (not part of this task).

## Constraints
- **No secrets in the Nix store or the repo.** The rclone config (`~/.config/rclone/rclone.conf`, remote name `gdrive`) is created manually with `rclone config` for now. Nix must NOT generate or overwrite it in phase 1.
- Do not use `programs.rclone.remotes` yet. That comes in phase 2 once SOPS is set up.
- Don't touch anything Insync-related; I'll remove Insync myself once the mount is proven.

## Phase 1 — do now
1. **Explore first.** Read the flake and module layout and tell me where you plan to put things before editing.
2. **Install rclone** via Home Manager (`home.packages = [ pkgs.rclone ];` or the repo's equivalent).
3. **Add a systemd user service** `rclone-gdrive` that mounts `gdrive:` at `~/GoogleDrive`:
   - Make it a small reusable module with options: enable, remote name, mount point, cache dir, cache max size.
   - Ensure the mount point and cache dir exist (`ExecStartPre=mkdir -p …` or HM equivalent).
   - Use `Type=notify` (rclone mount supports sd_notify), `Restart=on-failure`, `RestartSec=10`.
   - Set `Environment=PATH=/run/wrappers/bin:…` so `fusermount3` resolves.
   - Stop it with `ExecStop=fusermount3 -u <mountpoint>`.
   - Start after `network-online.target`, and install it into `default.target`.
   - Mount flags:
     ```
     --vfs-cache-mode full
     --cache-dir ~/.cache/rclone
     --vfs-cache-max-size 100G
     --vfs-cache-max-age 720h
     --vfs-write-back 10s
     --dir-cache-time 2m
     --poll-interval 1m
     --contimeout 15s
     --timeout 30s
     --drive-export-formats link.html
     ```
     (link.html makes Google Docs/Sheets open in the browser instead of creating editable .docx copies.)
   - The service must read the existing manual `~/.config/rclone/rclone.conf`. Note: if I've set a config password, the service will need `RCLONE_CONFIG_PASS` or `--password-command`. Flag this and ask me; don't guess.
4. **Stop indexers and thumbnailers crawling the mount**, which would download everything. Check which desktop/file manager the config uses and exclude `~/GoogleDrive` from indexing (Tracker / Baloo) and thumbnail generation where possible. If you can't do it declaratively, tell me what to do manually.
5. **Exclude `~/GoogleDrive` and `~/.cache/rclone` from any backup tooling** configured in the repo.
6. Build with `nixos-rebuild build --flake .#john-laptop` (or `home-manager build`, whichever the repo uses) and fix errors. Don't switch — I'll do that.

## Phase 2 — later, after SOPS is ready (don't do now)
- Move `client_id`, `client_secret` and `token` into sops-nix secrets.
- Switch to Home Manager's `programs.rclone.remotes.gdrive` with `secrets` pointing at the sops paths, or render `rclone.conf` from a sops template.
- Remember that rclone refreshes the OAuth token and writes it back to the config, so the generated config must be a writable file, not a store symlink.

## Acceptance checks (give me the commands)
- `systemctl --user status rclone-gdrive` is active.
- `ls ~/GoogleDrive` lists Drive instantly without downloading content.
- Opening a file populates `~/.cache/rclone/vfs/gdrive/…`.
- A new local file appears on drive.google.com within ~15s.
- Suspend/resume: the mount recovers, or the service restarts cleanly.
- `du -sh ~/.cache/rclone` stays small after browsing.

## Known gotchas
- No conflict handling: the last write wins. Don't keep git repos or code on the mount.
- Uncached files are unavailable offline. Uploads still pending at shutdown finish on the next start.
- Google allows duplicate filenames; I'll run `rclone dedupe gdrive:` before switching over.
- "Shared with me" isn't mounted by default (needs `--drive-shared-with-me` or a second remote). Out of scope for now.
