# sops-nix wiring shared by every host. See docs/sops.md.
#
# - At boot, secrets are decrypted with this machine's SSH host key.
# - Interactively, `sops` uses whichever registered YubiKey is plugged in
#   (SOPS_AGE_KEY_FILE points at the identity stubs). Fallbacks: `sops-host`, `sops-breakglass`.
#
# Hosts declare their own secrets, e.g.
#   sops.secrets.john-password.neededForUsers = true;              # from secrets/common.yaml
#   sops.secrets.foo.sopsFile = ../../secrets/<host>.yaml;          # host-only secret
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  keys = import ../../../secrets/keys.nix;
  host = config.networking.hostName;
  sops-tools = pkgs.callPackage ../../../scripts/sops-tools.nix {};
in {
  imports = [inputs.sops-nix.nixosModules.sops];

  sops = {
    defaultSopsFile = lib.mkDefault ../../../secrets/common.yaml;
    defaultSopsFormat = "yaml";
    # The host key is the only boot-time identity. No generated /var/lib/sops-nix/key.txt.
    age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
    gnupg.sshKeyPaths = [];
  };

  environment.systemPackages = with pkgs; [sops age age-plugin-yubikey ssh-to-age sops-tools];
  environment.variables.SOPS_AGE_KEY_FILE = "${../../../secrets/yubikey-identities.txt}";

  warnings = lib.optional (config.sops.secrets != {} && (keys.hosts.${host} or null) == null) ''
    ${host} declares sops secrets but has no key in secrets/keys.nix, so they will fail
    to decrypt at boot. Run `sops-new-host ${host}` (see docs/sops.md).
  '';
}
