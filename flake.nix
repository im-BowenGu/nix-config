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
    nixos-loading-plymouth = {
      url = "github:qboileau/nixos-load-plymouth";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    quickshell = {
      url = "git+https://git.outfoxxed.me/quickshell/quickshell";
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
    lazyvim-nix = {
      url = "github:pfassina/lazyvim-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nix-flatpak, nix-cachyos-kernel, nixos-loading-plymouth, noctalia, quickshell, stylix, awww, alejandra, lazyvim-nix, ... }@inputs: let
    system = "x86_64-linux";
    host = "thinkbook-16p";
    profile = "nvidia-intel-hybrid";

    mkNixosConfig = gpuProfile:
      nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit inputs;
          inherit host;
          inherit profile;
        };
        modules = [
          ./profiles/${gpuProfile}
          nix-flatpak.nixosModules.nix-flatpak
          nixos-loading-plymouth.nixosModules.default
          home-manager.nixosModules.home-manager
          {
            nixpkgs.overlays = [
              nix-cachyos-kernel.overlays.default
              (final: prev: {
                quickshell = quickshell.packages.${prev.stdenv.hostPlatform.system}.default;
              })
            ];
            home-manager.extraSpecialArgs = { inherit inputs; };
          }
        ];
      };
  in {
    nixosConfigurations = {
      thinkbook-16p = mkNixosConfig "nvidia-intel-hybrid";
    };

    formatter.x86_64-linux = inputs.alejandra.packages.x86_64-linux.default;
  };
}
