{ pkgs, lib, ... }:

let
  catppuccin = pkgs.catppuccin-gtk.override {
    variant = "mocha";
    accents = [ "lavender" ];
    size = "standard";
    tweaks = [ ];
  };
in {
  gtk = {
    enable = true;
    theme = {
      name = lib.mkForce "catppuccin-mocha-lavender-standard";
      package = lib.mkForce catppuccin;
    };
    gtk3.theme = lib.mkForce {
      name = "catppuccin-mocha-lavender-standard";
      package = catppuccin;
    };
    gtk4.theme = lib.mkForce {
      name = "catppuccin-mocha-lavender-standard";
      package = catppuccin;
    };
    cursorTheme = {
      name = "Nordzy-cursors";
      package = pkgs.nordzy-cursor-theme;
    };
  };

  home.pointerCursor = {
    gtk.enable = true;
    package = lib.mkForce pkgs.nordzy-cursor-theme;
    name = "Nordzy-cursors";
    size = 24;
  };
}