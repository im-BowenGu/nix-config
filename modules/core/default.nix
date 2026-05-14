{...}: {
  imports = [
    ./boot.nix
    ./network.nix
    ./system.nix
    ./user.nix
    ./security.nix
    ./bluetooth.nix
    ./flatpak.nix
    ./waydroid.nix
    ./audio.nix
    ./desktop.nix
    ./services.nix
  ];
}