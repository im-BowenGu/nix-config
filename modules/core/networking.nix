{ pkgs, ... }: {
  networking = {
    hostName = "thinkbook-16p";
    networkmanager.enable = true;
    networkmanager.wifi.backend = "iwd";
  };

  systemd.services.iwd.after = [ "systemd-udev-settle.service" ];

  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="net", KERNELS=="0000:82:00.0", NAME="wlp130s0f0"
  '';

  environment.systemPackages = with pkgs; [
    networkmanagerapplet
  ];
}
