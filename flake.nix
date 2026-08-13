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

    claude-desktop = {
      url = "github:k3d3/claude-desktop-linux-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Privacy-first voice dictation / transcription app.
    openwhispr = {
      url = "github:OpenWhispr/openwhispr";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ######################### macOS (Intel) ####################################
    # IMPORTANT: nixpkgs 26.11 (nixos-unstable, which `nixpkgs` above tracks) has
    # DROPPED support for x86_64-darwin. The Intel MacBook therefore cannot share
    # the main nixpkgs input and is pinned to the last release that supports it.
    #
    # That branch receives security fixes until the end of 2026 only. After that
    # this host has no supported nixpkgs, and the Nix-managed portion of it should
    # be retired in favour of Homebrew (or the machine replaced with Apple Silicon).
    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";

    # macOS system configuration (the darwin equivalent of nixosSystem).
    # Pinned to the matching 26.05 release branch, not master.
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };

    # Home Manager for darwin, matching the pinned 26.05 nixpkgs. The main
    # `home-manager` input above tracks master against unstable and would be
    # mismatched here.
    home-manager-darwin = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };

    # Installs and owns the Homebrew prefix itself, so there is no manual
    # `curl | bash` bootstrap. NOTE: this flake declares only a `brew-src` input
    # and has no nixpkgs input - there is nothing to `follows` here.
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
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
    claude-desktop,
    nix-darwin,
    nixpkgs-darwin,
    home-manager-darwin,
    ...
  }: let
    system = "x86_64-linux";

    # macOS short account name (`whoami` on the Mac). Single source of truth:
    # it is the home-manager.users key AND is threaded into both darwin modules
    # as a specialArg. These must agree - nix-darwin derives the default
    # home.homeDirectory from users.users.<key>.home, so a mismatched key makes
    # it resolve to null and fail with "not of type 'absolute path'".
    darwinUser = "johnstephenson";

    # `nix fmt` / `nix develop` targets. x86_64-darwin must come from the pinned
    # darwin nixpkgs - the main one no longer supports that platform at all.
    forEachDevSystem = f:
      {
        x86_64-linux = f (import nixpkgs {system = "x86_64-linux";});
      }
      // {
        x86_64-darwin = f (import nixpkgs-darwin {system = "x86_64-darwin";});
      };
  in {
    apps."x86_64-linux" = {
      default = {
        type = "app";
        program = "${self.nixosConfigurations.vm.config.system.build.vm}/bin/run-nixos-vm";
      };
    };

    # Sets formatter option. Defined for every dev system so that `nix fmt` works
    # on the MacBook too - it previously existed only for x86_64-linux.
    formatter = forEachDevSystem (pkgs: pkgs.alejandra);
    # Alternatives:
    # pkgs.nixfmt       # classic nixfmt
    # pkgs.alejandra    # widely used opinionated formatter

    # Development shell with linting and formatting tools
    devShells = forEachDevSystem (pkgs: {
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
    });

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

    ##################### DARWIN CONFIGURATIONS ######################
    # Intel work MacBook Pro. Build/switch with:
    #   darwin-rebuild switch --flake .#john-macbook
    #
    # Deliberately NOT added to `checks.x86_64-linux` above: it cannot be built
    # without a darwin builder and would break `nix flake check` on the Linux hosts.
    darwinConfigurations.john-macbook = nix-darwin.lib.darwinSystem {
      specialArgs = {
        inherit inputs;
        username = darwinUser;
      };
      modules = [
        ./hosts/john-macbook/default.nix

        # nix-index-database is deliberately omitted here: it tracks unstable and
        # would be mismatched against the pinned 26.05 darwin nixpkgs. Revisit in
        # slice 2 if `comma` turns out to be worth the version skew.
        home-manager-darwin.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "HMBackup"; # backup existing config before HM manages.
          # plasma-manager is Linux-only and sops is out of scope for slice 1,
          # so there are no sharedModules to add yet.

          # The key here MUST equal the macOS account name - see darwinUser above.
          home-manager.users.${darwinUser} = import ./home/john/john-macbook.nix;
          home-manager.extraSpecialArgs = {
            inherit inputs;
            system = "x86_64-darwin";
            username = darwinUser;
          };
        }
      ];
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
