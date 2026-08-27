## MuteMe Mini — illuminated USB HID mute button.
##
## The vendor's own Linux client is a proprietary download and its "stable"
## URL (https://downloads.muteme.com/releases/stable/default) currently 404s,
## so there is nothing pinnable to package. Instead this module builds
## MuteMagic, a small open-source userspace daemon that speaks the same HID
## protocol and drives PipeWire directly:
##
##   https://github.com/daniel-thompson/mutemagic-rs
##
## MuteMagic watches PipeWire for capture streams and reflects their mute
## state in the button LED (off = nothing capturing, green = live and
## unmuted, pulsing red = muted), and mutes/unmutes the streams when pressed.
## It is event driven — no polling, so zero wakeups while idle.
##
## Upstream only targets the MuteMe Original (0x42da) and hardcodes that
## product ID, so `productId` below patches it to the Mini's 0x42db. Flip the
## option back if a MuteMe Original is ever used on this host.
{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.muteme;

  # Upstream has no tagged release carrying the micropad work, so pin the commit.
  mutemagicSrc = pkgs.fetchFromGitHub {
    owner = "daniel-thompson";
    repo = "mutemagic-rs";
    rev = "27aaa7ddeb28f898351fe943f47b02ad9de230c7";
    hash = "sha256-RvlvsE+JuWMVt+ULmgD8ciDAvITTGPuJClv4GcUhZCA=";
  };

  mutemagic = pkgs.rustPlatform.buildRustPackage {
    pname = "mutemagic";
    version = "0.3.0-unstable-2026-03-03";

    src = mutemagicSrc;
    cargoLock.lockFile = "${mutemagicSrc}/Cargo.lock";

    # Point the daemon at whichever MuteMe model is plugged into this host.
    postPatch = ''
      substituteInPlace src/main.rs \
        --replace-fail "0x20a0, 0x42da" "0x20a0, ${cfg.productId}"
    '';

    # bindgenHook is needed by libspa-sys, which generates PipeWire bindings.
    nativeBuildInputs = with pkgs; [pkg-config rustPlatform.bindgenHook];
    buildInputs = with pkgs; [pipewire udev hidapi];

    meta = {
      description = "Linux userspace driver for USB HID mute buttons";
      homepage = "https://github.com/daniel-thompson/mutemagic-rs";
      license = licenses.gpl3Plus;
      mainProgram = "mutemagic-rs";
      platforms = platforms.linux;
    };
  };
  mutemeUdevRules = pkgs.writeTextFile {
    name = "muteme-udev-rules";
    destination = "/etc/udev/rules.d/60-muteme.rules";
    text = ''
      ACTION!="add", GOTO="muteme_end"
      SUBSYSTEM!="hidraw", GOTO="muteme_end"

      # MuteMe Original
      ATTRS{idVendor}=="20a0", ATTRS{idProduct}=="42da", TAG+="uaccess"
      # MuteMe Mini
      ATTRS{idVendor}=="20a0", ATTRS{idProduct}=="42db", TAG+="uaccess"

      LABEL="muteme_end"
    '';
  };
in {
  options.modules.muteme = {
    enable = mkEnableOption "MuteMe mute button support via the MuteMagic daemon";

    productId = mkOption {
      type = types.str;
      default = "0x42db";
      description = ''
        USB product ID of the attached MuteMe device. 0x42db is the MuteMe
        Mini, 0x42da the MuteMe Original. Vendor ID is always 0x20a0.
      '';
      example = "0x42da";
    };

    logLevel = mkOption {
      type = types.str;
      default = "info";
      description = "RUST_LOG level for the MuteMagic daemon (error/warn/info/debug/trace).";
    };
  };

  config = mkIf cfg.enable {
    # Raw HID access for the logged-in user. `uaccess` hands the seat owner an
    # ACL on the hidraw node, so the daemon runs as the user rather than root.
    # Both product IDs are tagged so swapping models needs no udev change.
    #
    # This MUST ship as a package rather than via services.udev.extraRules.
    # extraRules lands in 99-local.rules, but the uaccess builtin that actually
    # applies the ACL is invoked from systemd's 73-seat-late.rules. A tag added
    # at 99 is set too late to be seen — the node ends up tagged `uaccess` with
    # an empty ACL and the daemon sits logging "Waiting for add event" forever.
    # Hence 60-, matching upstream's 60-mutemagic.rules (and 60-steam-vr.rules).
    services.udev.packages = [mutemeUdevRules];

    # User service, not system: it needs the user's PipeWire session, and the
    # uaccess ACL is granted to the seat owner. Hotplug is handled internally
    # by the daemon's own udev monitor, so it can sit running with no device.
    systemd.user.services.mutemagic = {
      description = "MuteMagic - MuteMe button daemon";
      wantedBy = ["default.target"];
      requires = ["pipewire.socket"];
      after = ["pipewire.socket"];

      environment.RUST_LOG = cfg.logLevel;

      serviceConfig = {
        ExecStart = getExe mutemagic;
        Restart = "on-failure";
        RestartSec = 5;
      };
    };

    # Available on PATH for running by hand when debugging the button.
    environment.systemPackages = [mutemagic];
  };
}
