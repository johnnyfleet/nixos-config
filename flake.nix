{
  description = "VM";

  inputs = {
    ############ Official NixOS & Home Manager Package Sources #################

    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    #nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    # The next two are for pinning to stable vs unstable regardless of what the above is set to
    #nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.11";
    #nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      #url = "github:nix-community/home-manager/release-24.11";

      # The `follows` keyword in inputs is used for inheritance.
      # Here, `inputs.nixpkgs` of home-manager is kept consistent with
      # the `inputs.nixpkgs` of the current flake,
      # to avoid problems caused by different versions of nixpkgs.
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ############################ Utilities #####################################

    # Secrets management. See ./docs/secretsmgmt.md
    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      # IMPORTANT: we're using "libgbm" and is only available in unstable so ensure
      # to have it up to date or simply don't specify the nixpkgs input
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # To control the look and feel of the desktop environment.
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    # Custom config for devices.
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    # To be able to use comma we need an index to query.
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Run M365 via docker vm.
    winapps = {
      url = "github:winapps-org/winapps";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Manage provisioning through Nixos Anywhere.
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Niri scrollable-tiling Wayland compositor.
    niri = {
      url = "github:YaLTeR/niri";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    nixpkgs,
    self,
    home-manager,
    plasma-manager,
    sops-nix,
    zen-browser,
    nixos-hardware,
    nix-index-database,
    winapps,
    disko,
    niri,
    ...
  }: let
    system = "x86_64-linux";
  in {
    apps."x86_64-linux" = {
      default = {
        type = "app";
        program = "${self.nixosConfigurations.vm.config.system.build.vm}/bin/run-nixos-vm";
      };
    };

    # Sets formatter option
    formatter.x86_64-linux = let
      pkgs = import nixpkgs {system = "x86_64-linux";};
    in
      pkgs.alejandra;
    # Alternatives:
    # in pkgs.nixfmt       # classic nixfmt
    # in pkgs.alejandra    # widely used opinionated formatter

    nixosConfigurations.vm = nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs;};
      modules = [
        disko.nixosModules.disko
        ./hosts/nixos-anywhere-vm/default.nix
        nix-index-database.nixosModules.nix-index
        # optional to also wrap and install comma
        {programs.nix-index-database.comma.enable = true;}

        # make home-manager as a module of nixos
        # so that home-manager configuration will be deployed automatically when executing `nixos-rebuild switch`
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "HMBackup"; # backup existing config before HM manages.
          home-manager.sharedModules = [
            plasma-manager.homeManagerModules.plasma-manager
            inputs.sops-nix.homeManagerModules.sops
            nix-index-database.homeModules.nix-index
          ];

          home-manager.users.john = import ./home/john/nixos-anywhere-vm.nix;
          home-manager.extraSpecialArgs = {
            inherit inputs;
            system = "x86_64-linux";
          };

          # Optionally, use home-manager.extraSpecialArgs to pass arguments to home.nix
        }
      ];
    };

    nixosConfigurations.john-sony-laptop = nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs;};
      modules = [
        ./hosts/john-sony-laptop/default.nix
        nix-index-database.nixosModules.nix-index
        # optional to also wrap and install comma
        {programs.nix-index-database.comma.enable = true;}

        # make home-manager as a module of nixos
        # so that home-manager configuration will be deployed automatically when executing `nixos-rebuild switch`
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "HMBackup"; # backup existing config before HM manages.
          home-manager.sharedModules = [
            plasma-manager.homeManagerModules.plasma-manager
            inputs.sops-nix.homeManagerModules.sops
            nix-index-database.homeModules.nix-index
          ];

          home-manager.users.john = import ./home/john/john-sony-laptop.nix;
          home-manager.extraSpecialArgs = {
            inherit inputs;
            system = "x86_64-linux";
          };
          # Optionally, use home-manager.extraSpecialArgs to pass arguments to home.nix
        }
      ];
    };

    nixosConfigurations.john-laptop = nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs system;};
      modules = [
        ./hosts/john-laptop/default.nix
        nixos-hardware.nixosModules.lenovo-thinkpad-x1-9th-gen
        nix-index-database.nixosModules.nix-index
        # optional to also wrap and install comma
        {programs.nix-index-database.comma.enable = true;}

        # make home-manager as a module of nixos
        # so that home-manager configuration will be deployed automatically when executing `nixos-rebuild switch`
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "HMBackup"; # backup existing config before HM manages.
          home-manager.sharedModules = [
            plasma-manager.homeManagerModules.plasma-manager
            inputs.sops-nix.homeManagerModules.sops
            nix-index-database.homeModules.nix-index
          ];

          home-manager.users.john = import ./home/john/john-laptop.nix;
          home-manager.extraSpecialArgs = {
            inherit inputs;
            system = "x86_64-linux";
          };
          # Optionally, use home-manager.extraSpecialArgs to pass arguments to home.nix
        }

        (
          {
            pkgs,
            system ? pkgs.system,
            ...
          }: {
            # set up binary cache (optional)
            nix.settings = {
              substituters = ["https://winapps.cachix.org/"];
              trusted-public-keys = ["winapps.cachix.org-1:HI82jWrXZsQRar/PChgIx1unmuEsiQMQq+zt05CD36g="];
            };

            environment.systemPackages = [
              winapps.packages."${system}".winapps
              winapps.packages."${system}".winapps-launcher # optional
            ];
          }
        )
      ];
    };
  };
}
