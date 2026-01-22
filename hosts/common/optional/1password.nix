{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules._1password;
in {
  options.modules._1password = {
    enable = mkEnableOption "1Password password manager";

    enableCLI = mkOption {
      type = types.bool;
      default = true;
      description = "Enable 1Password CLI with SGUID wrapper";
    };

    enableGUI = mkOption {
      type = types.bool;
      default = true;
      description = "Enable 1Password GUI application";
    };

    polkitPolicyOwners = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Users authorized for polkit authentication";
      example = ["john" "alice"];
    };
  };

  config = mkIf cfg.enable {
    # Enable the 1Password CLI - also enables SGUID wrapper so CLI can authorize against GUI
    programs._1password = mkIf cfg.enableCLI {
      enable = true;
    };

    # Enable the 1Password GUI with specified users as authorized for polkit
    programs._1password-gui = mkIf cfg.enableGUI {
      enable = true;
      polkitPolicyOwners = cfg.polkitPolicyOwners;
    };
  };
}
