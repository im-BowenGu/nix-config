{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    waydroid
    waydroid-helper
    lxc
  ];

  boot.kernelModules = [ ];

  networking.nat.enable = true;
  networking.nat.internalIPs = [ "192.168.240.0/24" ];
  networking.nat.externalInterface = config.networking.defaultGateway.interface or "wlan0";

  networking.nftables.enable = true;

  systemd.services.waydroid-container = {
    enable = true;
    description = "Waydroid Container";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.waydroid}/bin/waydroid container start";
      ExecStop = "${pkgs.waydroid}/bin/waydroid container stop";
      Restart = "on-failure";
    };
  };

  users.groups.waydroid = {};
}