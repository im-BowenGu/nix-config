{ pkgs, ... }:

{
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  programs.uwsm = {
    enable = true;
    waylandCompositors.hyprland = {
      prettyName = "Hyprland";
      comment = "Hyprland managed by UWSM";
      binPath = "/run/current-system/sw/bin/Hyprland";
    };
  };

  services.gnome.gnome-keyring.enable = true;
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland pkgs.xdg-desktop-portal-gtk ];
    config = {
      common = {
        default = "hyprland";
        "org.freedesktop.impl.portal.Screenshot" = "hyprland";
        "org.freedesktop.impl.portal.ScreenCast" = "hyprland";
      };
    };
  };

  programs.nm-applet.enable = true;
  services.power-profiles-daemon.enable = true;
  services.gvfs.enable = true;
  services.tumbler.enable = true;
}
