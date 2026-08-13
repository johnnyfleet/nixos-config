# flake.nix
{
  inputs = {
    nixpkgs.url = "flake:nixpkgs/nixos-unstable";

    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    flake-utils,
    ...
  }: {
    # Sets formatter option (matches the root flake)
    formatter.x86_64-linux = let
      pkgs = import nixpkgs {system = "x86_64-linux";};
    in
      pkgs.alejandra;

    # nixos-generators was upstreamed into nixpkgs (NixOS 25.05), so the ISO is
    # built straight from the installer module's `system.build.isoImage`.
    nixosConfigurations.iso = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {
        inherit inputs;
      };
      modules = [
        #"${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
        "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares-plasma6.nix"
        ./images/iso.nix
        {
          system.stateVersion = "23.11";
        }
      ];
    };

    ## nix build .#iso
    ## nixcfg --build-iso && nixcfg --burn-iso 00000111112222333
    packages.x86_64-linux.iso = self.nixosConfigurations.iso.config.system.build.isoImage;
  };
}
