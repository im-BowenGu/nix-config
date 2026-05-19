{
  pkgs,
  lib,
  config,
  ...
}: {
  boot = {
    kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest-lto;
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    plymouth.nixos-loading = {
      enable = true;
      variant = "default"; # "default", "rainbow", or "white"
    };
    plymouth.theme = lib.mkForce "nixos-loading-default";
    kernelParams = [
      "quiet" "splash"
      "systemd.show_status=false"
      "rd.systemd.show_status=false"
    ];
    consoleLogLevel = 0;
    kernelPatches = [
      {
        name = "debloat-config";
        patch = null;
        extraConfig = ''
          DRM_QXL n
          DRM_VIRTIO_GPU n
          DRM_VKMS n
          BLK_DEV_IDE n
          FIREWIRE n
          PCMCIA n
          BLK_DEV_SKD n
          BLK_DEV_SX8 n
          BLK_DEV_NBD n
          BLK_DEV_RAM n
          ISDN n
          WAN n
          SERIAL_8250_RUNTIME_UARTS 0
        '';
      }
    ];
  };

  systemd.settings.Manager.DefaultTimeoutStopSec = "10s";

  systemd.services.systemd-udev-settle.enable = false;

  environment.systemPackages = with pkgs; [
    (pkgs.writeShellScriptBin "boot-timing" ''
      echo "=== systemd-analyze ==="
      systemd-analyze
      echo
      echo "=== systemd-analyze blame (top 20) ==="
      systemd-analyze blame | head -20
      echo
      echo "=== systemd-analyze critical-chain ==="
      systemd-analyze critical-chain
      echo
      echo "=== systemd-analyze plot ==="
      systemd-analyze plot > /tmp/boot-plot.svg 2>/dev/null && echo "Saved to /tmp/boot-plot.svg"
    '')
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
}
