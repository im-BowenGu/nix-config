{ inputs, ... }: {
  imports = [
    ./gtk.nix
    ./noctalia.nix
    ./bash.nix
    ./pywalfox.nix
    ./fastfetch.nix
    ./neovim.nix
    ./qt.nix
    ./terminals/kitty.nix
    ./hyprland
  ];
}
