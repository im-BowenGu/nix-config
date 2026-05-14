{
  description = "My NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-flatpak = {
      url = "github:gmodena/nix-flatpak?ref=v0.5.2";
    };
    nix-cachyos-kernel = {
      url = "github:xddxdd/nix-cachyos-kernel";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:danth/stylix/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    awww = {
      url = "git+https://codeberg.org/LGFae/awww";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    alejandra = {
      url = "github:kamadorueda/alejandra";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nix-flatpak, nix-cachyos-kernel, noctalia, stylix, awww, alejandra, ... }@inputs: {
    nixosConfigurations.thinkbook-16p = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        nix-flatpak.nixosModules.nix-flatpak
        ./profiles/nvidia-intel-hybrid
        home-manager.nixosModules.home-manager
        {
          nixpkgs.overlays = [
            nix-cachyos-kernel.overlays.default
          ];
          home-manager.extraSpecialArgs = { inherit inputs; };
        }
      ];
    };

    formatter.x86_64-linux = inputs.alejandra.packages.x86_64-linux.default;
  };
}