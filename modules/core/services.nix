{ pkgs, lib, config, ... }:

{
  services.greetd = {
    enable = true;
    settings = {
      initial_session = {
        user = "secret-star";
        command = "${pkgs.hyprland}/bin/start-hyprland";
      };
      default_session = {
        user = "secret-star";
        command = "${pkgs.hyprland}/bin/start-hyprland";
      };
    };
  };

  environment.sessionVariables = {
    XDG_SESSION_TYPE = "wayland";
    XDG_CURRENT_DESKTOP = "Hyprland";
  };

  environment.sessionVariables.XDG_DATA_DIRS = lib.mkForce [
    "/home/secret-star/.local/share/flatpak/exports/share"
    "/var/lib/flatpak/exports/share"
    "/usr/local/share"
    "/usr/share"
  ];
}
