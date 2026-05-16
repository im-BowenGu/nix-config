{ inputs, ... }: {
  imports = [
    ./gtk.nix
    ./noctalia.nix
    ./bash.nix
    ./qt.nix
    ./terminals/kitty.nix
    ./hyprland
  ];
}
