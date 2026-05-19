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
        name = "proc-uptime-kexec-stitch";
        patch = ../../patches/proc-uptime-kexec-stitch.patch;
      }
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

  systemd.services.clear-stale-kexec = {
    description = "Clear kexec uptime baseline on true cold boots";
    after = [ "local-fs.target" ];
    wantedBy = [ "multi-user.target" ];
    script = ''
      if ! grep -q "woke_from_kexec=1" /proc/cmdline; then
        rm -f /var/lib/kexec_base_uptime
      fi
    '';
  };

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
    (pkgs.writeShellScriptBin "nixos-kexec-switch" ''
      set -e

      SYS_PATH="/nix/var/nix/profiles/system"
      KERNEL=$(readlink -f "$SYS_PATH/kernel")
      INITRD=$(readlink -f "$SYS_PATH/initrd")
      PARAMS=$(cat "$SYS_PATH/kernel-params")
      INIT=$(readlink -f "$SYS_PATH/init")

      CURRENT_KERN=$(cat /proc/uptime | awk '{print $1}')
      if [ -f /var/lib/kexec_base_uptime ]; then
        PREV_BASE=$(cat /var/lib/kexec_base_uptime)
        NEW_BASE=$(echo "$PREV_BASE + $CURRENT_KERN" | ${pkgs.bc}/bin/bc)
      else
        NEW_BASE=$CURRENT_KERN
      fi

      echo "$NEW_BASE" > /var/lib/kexec_base_uptime
      echo "Staging cumulative uptime base: $NEW_BASE seconds"

      ${pkgs.kexec-tools}/bin/kexec -l "$KERNEL" \
        --initrd="$INITRD" \
        --append="$PARAMS init=$INIT woke_from_kexec=1"

      systemctl kexec
    '')
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
}
