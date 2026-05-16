{ pkgs, lib, ... }:

{
  qt = {
    enable = true;
    platformTheme.name = lib.mkForce "kde";
    style = {
      name = lib.mkForce "kvantum";
      package = lib.mkForce pkgs.kdePackages.qtstyleplugin-kvantum;
    };
  };

  xdg.configFile."Kvantum/kvantum.kvconfig" = {
    source = lib.mkForce (toString ./dotfiles/Kvantum/kvantum.kvconfig);
  };

  xdg.configFile."Kvantum/catppuccin-mocha-lavender" = {
    source = lib.mkForce (toString ./dotfiles/Kvantum/catppuccin-mocha-lavender);
    recursive = true;
  };
}
