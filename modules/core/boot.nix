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
    kernelPatches = [{
      name = "strip-unused-drivers";
      patch = null;
      extraConfig = ''
        # No non-Intel ethernet
        NET_VENDOR_3COM n
        NET_VENDOR_ADAPTEC n
        NET_VENDOR_AGERE n
        NET_VENDOR_ALACRITECH n
        NET_VENDOR_ALTEON n
        NET_VENDOR_AMAZON n
        NET_VENDOR_AMD n
        NET_VENDOR_AQUANTIA n
        NET_VENDOR_ARCHEMU n
        NET_VENDOR_ASIX n
        NET_VENDOR_ATHEROS n
        NET_VENDOR_BROADCOM n
        NET_VENDOR_BROCADE n
        NET_VENDOR_CADENCE n
        NET_VENDOR_CAVIUM n
        NET_VENDOR_CHELSIO n
        NET_VENDOR_CIRRUS n
        NET_VENDOR_CISCO n
        NET_VENDOR_CORTINA n
        NET_VENDOR_DAVICOM n
        NET_VENDOR_DEC n
        NET_VENDOR_DLINK n
        NET_VENDOR_EMC n
        NET_VENDOR_ENGLEDER n
        NET_VENDOR_EZCHIP n
        NET_VENDOR_FARADAY n
        NET_VENDOR_FREESCALE n
        NET_VENDOR_FUJITSU n
        NET_VENDOR_FUNGIBLE n
        NET_VENDOR_GOOGLE n
        NET_VENDOR_HISILICON n
        NET_VENDOR_HUAWEI n
        NET_VENDOR_I825XX n
        NET_VENDOR_ADIN n
        NET_VENDOR_LITEX n
        NET_VENDOR_MARVELL n
        NET_VENDOR_MELLANOX n
        NET_VENDOR_MICREL n
        NET_VENDOR_MICROCHIP n
        NET_VENDOR_MICROSEMI n
        NET_VENDOR_MICROSOFT n
        NET_VENDOR_MYRI n
        NET_VENDOR_NATSEMI n
        NET_VENDOR_NETERION n
        NET_VENDOR_NETRONOME n
        NET_VENDOR_NI n
        NET_VENDOR_NVIDIA n
        NET_VENDOR_OKI n
        NET_VENDOR_PACKET_ENGINES n
        NET_VENDOR_PENSANDO n
        NET_VENDOR_QLOGIC n
        NET_VENDOR_QUALCOMM n
        NET_VENDOR_RENESAS n
        NET_VENDOR_ROCKER n
        NET_VENDOR_SAMSUNG n
        NET_VENDOR_SEEQ n
        NET_VENDOR_SILAN n
        NET_VENDOR_SIS n
        NET_VENDOR_SOLARFLARE n
        NET_VENDOR_SMSC n
        NET_VENDOR_SOCIONEXT n
        NET_VENDOR_STMICRO n
        NET_VENDOR_SUN n
        NET_VENDOR_SYNOPSYS n
        NET_VENDOR_TEHUTI n
        NET_VENDOR_TI n
        NET_VENDOR_VERTEXCOM n
        NET_VENDOR_VIA n
        NET_VENDOR_WANGXUN n
        NET_VENDOR_WIZNET n
        NET_VENDOR_XILINX n
        USB_NET_DRIVERS m

        # No AMD/ATI GPU drivers
        DRM_AMDGPU n
        DRM_RADEON n
        DRM_NOUVEAU n
        DRM_VMWGFX n
        DRM_VGEM n
        DRM_UDL n
        DRM_AST n
        DRM_BOCHS n
        DRM_CIRRUS_QEMU n
        DRM_GM12U32 n
        DRM_QXL n
        DRM_VIRTIO_GPU n
        DRM_VKMS n

        # Keep SATA/AHCI (needed by initrd)
        # ATA n
        BLK_DEV_IDE n

        # No FireWire
        FIREWIRE n

        # No PCMCIA
        PCMCIA n

        # No MMC/SD
        # MMC n

        # No old storage
        BLK_DEV_SKD n
        BLK_DEV_SX8 n
        BLK_DEV_NBD n
        BLK_DEV_RAM n

        # No ISDN
        ISDN n

        # No WAN
        WAN n

        # Reduce serial UARTs to 0
        SERIAL_8250_RUNTIME_UARTS 0
      '';
    }];
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
