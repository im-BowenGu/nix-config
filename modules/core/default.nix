{
  inputs,
  host,
  ...
}: let
  vars = import ../../hosts/${host}/variables.nix;
in {
  imports = [
    ./ai.nix
    ./audio.nix
    ./bluetooth.nix
    ./boot.nix
    ./desktop.nix
    ./flatpak.nix
    ./fonts.nix
    ./gatwy.nix
    ./networking.nix
    ./packages.nix
    ./security.nix
    ./services.nix
    ./stylix.nix
    ./time.nix
    ./users.nix
    ./waydroid.nix
    inputs.stylix.nixosModules.stylix
  ];
}
