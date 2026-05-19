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

  systemd.tmpfiles.settings."tuptime" = {
    "/var/lib/tuptime".d = {
      user = "root";
      group = "root";
      mode = "0755";
    };
  };

  systemd.services.tuptime-graceful = {
    description = "Mark tuptime shutdown as graceful";
    before = [ "shutdown.target" ];
    wantedBy = [ "shutdown.target" ];
    conflicts = [ "shutdown.target" ];
    unitConfig.DefaultDependencies = false;
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.coreutils}/bin/true";
      ExecStop = "${pkgs.tuptime}/bin/tuptime -gq";
    };
  };

  systemd.services.battery-conserve = {
    description = "Enable Lenovo battery conservation mode (cap at ~60%)";
    wantedBy = [ "multi-user.target" ];
    after = [ "sysinit.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      echo 1 > /sys/devices/pci0000:00/0000:00:1f.0/PNP0C09:00/VPC2004:00/conservation_mode
    '';
  };
}
