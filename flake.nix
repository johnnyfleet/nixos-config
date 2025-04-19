{
  description = "VM";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # The next two are for pinning to stable vs unstable regardless of what the above is set to
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      # IMPORTANT: we're using "libgbm" and is only available in unstable so ensure
      # to have it up to date or simply don't specify the nixpkgs input  
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      #url = "github:nix-community/home-manager/release-24.11"  

      # The `follows` keyword in inputs is used for inheritance.
      # Here, `inputs.nixpkgs` of home-manager is kept consistent with
      # the `inputs.nixpkgs` of the current flake,
      # to avoid problems caused by different versions of nixpkgs.
      inputs.nixpkgs.follows = "nixpkgs";

    };
    # Secrets management. See ./docs/secretsmgmt.md
    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    
    # To be able to use comma we need an index to query.
    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      nixpkgs,
      self,
      home-manager,
      plasma-manager,
      sops-nix,
      zen-browser,
      nixos-hardware,
      nix-index-database,
      ...
    }@inputs:
    {
      apps."x86_64-linux" = {
        default = {
          type = "app";
          program = "${self.nixosConfigurations.vm.config.system.build.vm}/bin/run-nixos-vm";
        };
      };
      nixosConfigurations.vm = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/nixos-anywhere-vm/default.nix
          nix-index-database.nixosModules.nix-index

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
            ];

            # TODO replace ryan with your own username
            home-manager.users.john = import ./home/john/nixos-anywhere-vm.nix;
            home-manager.extraSpecialArgs = { inherit inputs; system = "x86_64-linux";};

            # Optionally, use home-manager.extraSpecialArgs to pass arguments to home.nix
          }
        ];
      };

      nixosConfigurations.vm-plasma = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/nixos-plasma-vm/default.nix
          nix-index-database.nixosModules.nix-index

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
            ];

            # TODO replace ryan with your own username
            home-manager.users.john = import ./home/john/nixos-plasma-vm.nix;
            home-manager.extraSpecialArgs = { inherit inputs; system = "x86_64-linux";};

            # Optionally, use home-manager.extraSpecialArgs to pass arguments to home.nix
          }
        ];
      };

      nixosConfigurations.john-sony-laptop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/john-sony-laptop/default.nix
          nix-index-database.nixosModules.nix-index

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
            ];

            # TODO replace ryan with your own username
            home-manager.users.john = import ./home/john/john-sony-laptop.nix;
            home-manager.extraSpecialArgs = { inherit inputs; system = "x86_64-linux";};
            # Optionally, use home-manager.extraSpecialArgs to pass arguments to home.nix
          }
        ];
      };

      nixosConfigurations.john-laptop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/john-laptop/default.nix
          nixos-hardware.nixosModules.lenovo-thinkpad-x1-9th-gen
          nix-index-database.nixosModules.nix-index

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
              nix-index-database.hmModules.nix-index
            ];

            # TODO replace ryan with your own username
            home-manager.users.john = import ./home/john/john-laptop.nix;
            home-manager.extraSpecialArgs = { inherit inputs; system = "x86_64-linux";};
            # Optionally, use home-manager.extraSpecialArgs to pass arguments to home.nix
          }
        ];
      };

    };
}