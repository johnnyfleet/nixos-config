# flake.nix
{
  inputs = {
    nixpkgs.url = "flake:nixpkgs/nixos-unstable";

    flake-utils.url = "github:numtide/flake-utils";

    nixos-generators.url = "github:nix-community/nixos-generators";
    nixos-generators.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    flake-utils,
    ...
  }: {
    ## nix build .#iso
    ## nixcfg --build-iso && nixcfg --burn-iso 00000111112222333
    packages.x86_64-linux.iso = inputs.nixos-generators.nixosGenerate {
      system = "x86_64-linux";
      format = "install-iso";
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
  };
}
