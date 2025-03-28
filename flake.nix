{
  description = "VM";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # The next two are for pinning to stable vs unstable regardless of what the above is set to
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      #url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs =
    { nixpkgs, self, home-manager, plasma-manager, sops-nix, ... }@inputs:
    let
      # Define an overlay for the hplip package fix.
      hplipOverlay = (final: prev: {
        hplip = prev.hplip.overrideAttrs (old: rec {
          plugin = prev.fetchurl {
            url = "https://developers.hp.com/sites/default/files/hplip-3.24.4-plugin.run";
            hash = "sha256-Hzxr3SVmGoouGBU2VdbwbwKMHZwwjWnI7P13Z6LQxao=";
            curlOptsList = [
              "-A"
              "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.159 Safari/537.36"
            ];
          };
        });
      });
      # Create a home-manager package set that includes the overlay.
      hmPkgs = import nixpkgs {
        system = "x86_64-linux";
        overlays = [ hplipOverlay ];
      };
    in {
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
          {
            # (Optional) apply the overlay to system packages if needed.
            nixpkgs.overlays = [ hplipOverlay ];
          }
          home-manager.nixosModules.home-manager {
            # Disable use of global pkgs and provide our custom package set.
            home-manager.useGlobalPkgs = false;
            home-manager.useUserPackages = true;
            home-manager.pkgs = hmPkgs;
            home-manager.sharedModules = [
              plasma-manager.homeManagerModules.plasma-manager
              inputs.sops-nix.homeManagerModules.sops
            ];
            home-manager.users.john = import ./home/john/nixos-anywhere-vm.nix;
          }
        ];
      };

      nixosConfigurations.vm-plasma = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/nixos-plasma-vm/default.nix
          {
            nixpkgs.overlays = [ hplipOverlay ];
          }
          home-manager.nixosModules.home-manager {
            home-manager.useGlobalPkgs = false;
            home-manager.useUserPackages = true;
            home-manager.pkgs = hmPkgs;
            home-manager.sharedModules = [
              plasma-manager.homeManagerModules.plasma-manager
              inputs.sops-nix.homeManagerModules.sops
            ];
            home-manager.users.john = import ./home/john/nixos-plasma-vm.nix;
          }
        ];
      };

      nixosConfigurations.john-sony-laptop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/john-sony-laptop/default.nix
          {
            nixpkgs.overlays = [ hplipOverlay ];
          }
          home-manager.nixosModules.home-manager {
            home-manager.useGlobalPkgs = false;
            home-manager.useUserPackages = true;
            home-manager.pkgs = hmPkgs;
            home-manager.sharedModules = [
              plasma-manager.homeManagerModules.plasma-manager
              inputs.sops-nix.homeManagerModules.sops
            ];
            home-manager.users.john = import ./home/john/john-sony-laptop.nix;
          }
        ];
      };
    };
}
