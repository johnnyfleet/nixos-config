# Adds YubiKey authentication support via U2F to sudo, display manager unlock.
{
  config,
  lib,
  pkgs,
  ...
}: {
  # Polkit 127 sandboxes polkit-agent-helper-1 in a systemd transient service with:
  #   PrivateDevices=yes  → private /dev with no hardware devices (hidraw invisible)
  #   DevicePolicy=strict → only /dev/null allowed via cgroup
  #   ProtectHome=yes     → /home inaccessible (blocks ~/.config/Yubico/u2f_keys)
  # pam_u2f needs hidraw access (FIDO2 USB HID) and the per-user key file.
  # This drop-in relaxes those restrictions so FIDO2 works in polkit dialogs.
  systemd.services."polkit-agent-helper@" = {
    serviceConfig = {
      PrivateDevices = lib.mkForce false; # expose real /dev so hidraw devices are visible
      DevicePolicy = lib.mkForce "auto"; # allow devices in DeviceAllow list (+ inherited /dev/null)
      DeviceAllow = [ "char-hidraw rw" ]; # adds all hidraw devices (FIDO2 uses these)
      ProtectHome = lib.mkForce "read-only"; # allow reading ~/.config/Yubico/u2f_keys
    };
  };
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

  # 2b) POLKIT-1: GUI sudo prompts (KDE/Plasma) - YubiKey first, then password
  # fprintAuth must be false: KDE's polkit agent authenticates fingerprint via fprintd D-Bus
  # independently of PAM, closing the dialog before pam_u2f can respond. FIDO2 never gets
  # a chance to run. Fingerprint still works for kscreenlocker, sddm, and sudo.
  security.pam.services.polkit-1 = {
    u2fAuth = true;
    fprintAuth = false;
    unixAuth = true;
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
