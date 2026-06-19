## OpenWhispr — privacy-first voice dictation / transcription.
## Wraps the upstream flake's NixOS module (inputs.openwhispr) and exposes it
## through this repo's `modules.<name>` options convention.
##
## Enabling this turns on programs.ydotool + hardware.uinput and grants the
## listed users access to /dev/uinput so Wayland auto-paste works.
{
  config,
  lib,
  inputs,
  ...
}:
with lib; let
  cfg = config.modules.openwhispr;
in {
  imports = [inputs.openwhispr.nixosModules.default];

  options.modules.openwhispr = {
    enable = mkEnableOption "OpenWhispr — voice dictation with Wayland auto-paste";

    users = mkOption {
      type = types.listOf types.str;
      default = ["john"];
      description = "Users granted ydotool/uinput access for Wayland auto-paste";
    };
  };

  config = mkIf cfg.enable {
    programs.openwhispr = {
      enable = true;
      users = cfg.users;
    };
  };
}
