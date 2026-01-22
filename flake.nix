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
    # winapps = {
    #   url = "github:winapps-org/winapps";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

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
    #winapps,
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

    # Development shell with linting and formatting tools
    devShells.x86_64-linux = let
      pkgs = import nixpkgs {system = "x86_64-linux";};
    in {
      default = pkgs.mkShell {
        name = "nixos-config";
        buildInputs = with pkgs; [
          # Nix tools
          alejandra # Nix formatter
          statix # Nix linter
          deadnix # Find dead code in Nix
          nix-tree # Visualize nix dependencies

          # Git hooks
          pre-commit

          # Secrets management
          sops
          age

          # Useful utilities
          nil # Nix LSP
          nixfmt-classic # Alternative formatter
        ];

        shellHook = ''
          echo "NixOS Config Development Shell"
          echo ""
          echo "Available commands:"
          echo "  nix fmt        - Format all Nix files"
          echo "  statix check   - Lint Nix files"
          echo "  deadnix        - Find dead code"
          echo "  nix flake check - Verify flake"
          echo ""
          echo "To set up pre-commit hooks: pre-commit install"
        '';
      };
    };

    # Expose custom library functions
    lib = import ./lib {
      inherit (nixpkgs) lib;
      pkgs = import nixpkgs {system = "x86_64-linux";};
      inherit inputs;
    };

    # Export overlays for external use
    overlays = import ./overlays;

    # Export NixOS modules for external use
    nixosModules = {
      # Optional feature modules
      docker = ./hosts/common/optional/docker.nix;
      syncthing = ./hosts/common/optional/syncthing.nix;
      virtualisation = ./hosts/common/optional/virtualisation.nix;
      _1password = ./hosts/common/optional/1password.nix;
      steam = ./hosts/common/optional/steam.nix;
      flatpak = ./hosts/common/optional/flatpak.nix;
      printing = ./hosts/common/optional/printing.nix;
      niri = ./hosts/common/optional/niri.nix;
      tlp = ./hosts/common/optional/tlp.nix;
      fwupd = ./hosts/common/optional/fwupd.nix;

      # Core modules
      core = ./hosts/common/core/default.nix;

      # Feature system
      options = ./hosts/common/options.nix;
      features = ./hosts/common/features.nix;

      # Profiles
      profiles = {
        minimal = ./profiles/minimal.nix;
        desktop = ./profiles/desktop.nix;
        workstation = ./profiles/workstation.nix;
        gaming = ./profiles/gaming.nix;
        server = ./profiles/server.nix;
      };
    };

    # Export Home Manager modules for external use
    homeManagerModules = {
      devTools = ./home/john/optional/dev-tools.nix;
      gaming = ./home/john/optional/gaming.nix;
      regularPrograms = ./home/john/optional/regular-programs.nix;
      workApplications = ./home/john/optional/work-applications.nix;
      vmTools = ./home/john/optional/vm-tools.nix;
      obsStudio = ./home/john/optional/obs-studio.nix;
      plasmaManager = ./home/john/optional/plasma-manager.nix;
    };

    # Flake checks for validation
    checks.x86_64-linux = let
      pkgs = import nixpkgs {system = "x86_64-linux";};
    in {
      # Verify all configurations build
      vm = self.nixosConfigurations.vm.config.system.build.toplevel;
      john-laptop = self.nixosConfigurations.john-laptop.config.system.build.toplevel;
      john-sony-laptop = self.nixosConfigurations.john-sony-laptop.config.system.build.toplevel;

      # Formatting check
      formatting = pkgs.runCommand "check-formatting" {} ''
        ${pkgs.alejandra}/bin/alejandra --check ${./.} && touch $out
      '';
    };

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
            plasma-manager.homeModules.plasma-manager
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
        disko.nixosModules.disko
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
            plasma-manager.homeModules.plasma-manager
            inputs.sops-nix.homeManagerModules.sops
            nix-index-database.homeModules.nix-index
          ];

          home-manager.users.john = import ./home/john/john-sony-laptop.nix;
          home-manager.users.kiran = import ./home/kiran/john-sony-laptop.nix;
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
            plasma-manager.homeModules.plasma-manager
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

        /*
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
        */
      ];
    };
  };
}
