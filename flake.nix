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
      # Optional: a system-wide overlay. This will override hplip for packages built via the system.
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
            # Apply the overlay for system packages (if needed).
            nixpkgs.overlays = [ hplipOverlay ];
          }
          # Home-manager as a NixOS module with packageOverrides added.
          home-manager.nixosModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.sharedModules = [
              plasma-manager.homeManagerModules.plasma-manager
              inputs.sops-nix.homeManagerModules.sops
            ];
            # Override hplip in the home-manager package set.
            home-manager.packageOverrides = pkgs: {
              hplip = pkgs.hplip.overrideAttrs (old: rec {
                plugin = pkgs.fetchurl {
                  url = "https://developers.hp.com/sites/default/files/hplip-3.24.4-plugin.run";
                  hash = "sha256-Hzxr3SVmGoouGBU2VdbwbwKMHZwwjWnI7P13Z6LQxao=";
                  curlOptsList = [
                    "-A"
                    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.159 Safari/537.36"
                  ];
                };
              });
            };
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
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.sharedModules = [
              plasma-manager.homeManagerModules.plasma-manager
              inputs.sops-nix.homeManagerModules.sops
            ];
            home-manager.packageOverrides = pkgs: {
              hplip = pkgs.hplip.overrideAttrs (old: rec {
                plugin = pkgs.fetchurl {
                  url = "https://developers.hp.com/sites/default/files/hplip-3.24.4-plugin.run";
                  hash = "sha256-Hzxr3SVmGoouGBU2VdbwbwKMHZwwjWnI7P13Z6LQxao=";
                  curlOptsList = [
                    "-A"
                    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.159 Safari/537.36"
                  ];
                };
              });
            };
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
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.sharedModules = [
              plasma-manager.homeManagerModules.plasma-manager
              inputs.sops-nix.homeManagerModules.sops
            ];
            home-manager.packageOverrides = pkgs: {
              hplip = pkgs.hplip.overrideAttrs (old: rec {
                plugin = pkgs.fetchurl {
                  url = "https://developers.hp.com/sites/default/files/hplip-3.24.4-plugin.run";
                  hash = "sha256-Hzxr3SVmGoouGBU2VdbwbwKMHZwwjWnI7P13Z6LQxao=";
                  curlOptsList = [
                    "-A"
                    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.159 Safari/537.36"
                  ];
                };
              });
            };
            home-manager.users.john = import ./home/john/john-sony-laptop.nix;
          }
        ];
      };
    };
}
