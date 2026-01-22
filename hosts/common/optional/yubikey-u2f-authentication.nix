# Adds YubiKey authentication support via U2F to sudo, display manager unlock.
{
  config,
  lib,
  pkgs,
  ...
}: {
  # 1) Enable U2F and (optionally) fingerprint
  security.pam.u2f = {
    enable = true;
    settings.cue = true; # prompt "Touch your U2F device"
    control = "sufficient"; # default control flag when used via include helpers
    # We use per-user files (~/.config/Yubico/u2f_keys), so no authFile needed here
  };

  # Enable fingerprint
  services.fprintd = {
    enable = true;
    tod.enable = true;
    tod.driver = pkgs.libfprint-2-tod1-goodix;
  };

  # 2) SUDO: YubiKey OR fingerprint OR password
  security.pam.services.sudo = {
    u2fAuth = true;
    fprintAuth = true;
    unixAuth = true; # password fallback via system-auth
  };

  # 3) DISPLAY MANAGER PASSWORD PROMPT (Unlock): OR across YubiKey / fingerprint / password
  # --- SDDM / KDE (login dialog) ---
  # Uncomment if you use SDDM instead of GDM:
  security.pam.services.sddm = {
    u2fAuth = true;
    fprintAuth = true;
    unixAuth = true;
  };

  # 4) SCREEN LOCKERS:
  # KDE’s lock screen:
  security.pam.services.kscreenlocker = {
    u2fAuth = true;
    fprintAuth = true;
    unixAuth = true;
  };

  # 5) INITIAL LOGIN (TTY getty): PASSWORD ONLY, no U2F/fingerprint
  # Typically only have password as otherwise you need to manually unlock Kwallet anyway - which is annoying experience.
  security.pam.services.login = {
    u2fAuth = false;
    fprintAuth = false;
    unixAuth = true;
  };
}
