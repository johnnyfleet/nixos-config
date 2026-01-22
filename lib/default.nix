# Custom library functions for NixOS configuration
{
  lib,
  pkgs,
  inputs,
  ...
}: rec {
  # Fetch SSH public keys from a GitHub user
  # Usage: fetchGitHubKeys { inherit pkgs; username = "johnnyfleet"; }
  fetchGitHubKeys = {
    pkgs,
    username,
    sha256 ? lib.fakeSha256,
  }: let
    authorizedKeys = pkgs.fetchurl {
      url = "https://github.com/${username}.keys";
      inherit sha256;
    };
  in
    lib.splitString "\n" (builtins.readFile authorizedKeys);

  # Create a standardized user configuration
  # Usage: mkUser { username = "john"; description = "John Doe"; extraGroups = ["wheel"]; ... }
  mkUser = {
    username,
    description ? "",
    extraGroups ? ["wheel"],
    shell ? pkgs.zsh,
    initialHashedPassword ? null,
    hashedPasswordFile ? null,
    sshKeysSha256 ? null,
    githubUsername ? null,
  }: {
    users.users.${username} =
      {
        isNormalUser = true;
        inherit description extraGroups;
        shell = shell;
      }
      // lib.optionalAttrs (initialHashedPassword != null) {
        inherit initialHashedPassword;
      }
      // lib.optionalAttrs (hashedPasswordFile != null) {
        inherit hashedPasswordFile;
      }
      // lib.optionalAttrs (githubUsername != null && sshKeysSha256 != null) {
        openssh.authorizedKeys.keys = fetchGitHubKeys {
          inherit pkgs;
          username = githubUsername;
          sha256 = sshKeysSha256;
        };
      };

    programs.zsh.enable = lib.mkIf (shell == pkgs.zsh) true;
  };

  # Create a standardized NixOS host configuration
  # Usage: mkHost { hostname = "john-laptop"; system = "x86_64-linux"; ... }
  mkHost = {
    hostname,
    system ? "x86_64-linux",
    stateVersion ? "24.05",
    modules ? [],
    homeManagerUsers ? {},
    extraSpecialArgs ? {},
    overlays ? [],
    hardwareModules ? [],
  }: let
    pkgs = import inputs.nixpkgs {
      inherit system;
      config.allowUnfree = true;
      overlays = overlays;
    };
  in
    inputs.nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs =
        {
          inherit inputs system;
        }
        // extraSpecialArgs;
      modules =
        [
          # Apply overlays
          {nixpkgs.overlays = overlays;}
        ]
        ++ hardwareModules
        ++ modules
        ++ [
          # Home Manager integration
          inputs.home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "HMBackup";
            home-manager.sharedModules = [
              inputs.plasma-manager.homeModules.plasma-manager
              inputs.sops-nix.homeManagerModules.sops
              inputs.nix-index-database.homeModules.nix-index
            ];
            home-manager.users = homeManagerUsers;
            home-manager.extraSpecialArgs =
              {
                inherit inputs system;
              }
              // extraSpecialArgs;
          }
        ];
    };

  # Recursively scan a directory and import all .nix files
  # Usage: scanPaths ./hosts/common/optional
  scanPaths = path: let
    entries = builtins.readDir path;
    # Filter for .nix files and directories
    nixFiles = lib.filterAttrs (name: type: type == "regular" && lib.hasSuffix ".nix" name && name != "default.nix") entries;
    directories = lib.filterAttrs (name: type: type == "directory") entries;
    # Import nix files
    importFile = name: _: path + "/${name}";
    # Recursively scan directories
    importDir = name: _: scanPaths (path + "/${name}");
  in
    (lib.mapAttrsToList importFile nixFiles)
    ++ (lib.flatten (lib.mapAttrsToList importDir directories));

  # Import all modules from a directory (for use in imports = [...])
  # Usage: imports = importModules ./hosts/common/core;
  importModules = path:
    builtins.filter (p: builtins.pathExists p) (scanPaths path);

  # Create a feature flag option
  # Usage: mkFeatureOption "gaming" "Enable gaming support (Steam, Wine, etc.)"
  mkFeatureOption = name: description:
    lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to enable ${description}";
    };

  # Helper to merge multiple attrsets deeply
  # Usage: recursiveMerge [ { a = 1; } { b = 2; } ]
  recursiveMerge = attrList:
    lib.foldl' lib.recursiveUpdate {} attrList;
}
