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
  services.fwupd.enable = true;

  environment.sessionVariables.XDG_DATA_DIRS = lib.mkForce [
    "/home/secret-star/.local/share/flatpak/exports/share"
    "/var/lib/flatpak/exports/share"
    "/usr/local/share"
    "/usr/share"
  ];
  virtualisation.libvirtd.enable = true;
  networking.firewall.checkReversePath = "loose";
  networking.firewall.trustedInterfaces = [ "virbr0" ];
  networking.firewall.allowedTCPPorts = [ 443 ];

  services.caddy = {
    enable = true;
    virtualHosts."10.160.3.104" = {
      extraConfig = ''
        bind 0.0.0.0
        reverse_proxy https://localhost:7443 {
          transport http {
            tls_insecure_skip_verify
          }
        }
        tls internal
      '';
    };
  };
}
