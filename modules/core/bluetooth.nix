{ pkgs, ... }:

{
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  systemd.user.services.blueman-applet = {
    serviceConfig.ExecStart = [ "" "${pkgs.blueman}/bin/blueman-applet" ];
    serviceConfig.Type = "dbus";
    serviceConfig.BusName = "org.blueman.Applet";
    serviceConfig.Restart = "on-failure";
  };
}