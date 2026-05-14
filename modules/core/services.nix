{ pkgs, lib, config, ... }:

{
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    autoNumlock = true;
  };

  services.displayManager.genericEnvironment = {
    XDG_SESSION_TYPE = "wayland";
    XDG_CURRENT_DESKTOP = "Hyprland";
  };

  home.sessionVariables = {
    XDG_DATA_DIRS = "${config.home.homeDirectory}/.local/share/flatpak/exports/share:/var/lib/flatpak/exports/share:/usr/local/share:/usr/share";
  };
}