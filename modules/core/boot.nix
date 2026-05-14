{
  pkgs,
  config,
  inputs,
  ...
}: {
  boot = {
    kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest-lto;
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  fileSystems."/data" = {
    device = "/dev/disk/by-uuid/94b6bb2e-8d32-400d-98a0-988ae9dc6a1d";
    fsType = "btrfs";
    options = [ "rw" "relatime" "ssd" "discard=async" "space_cache=v2" "subvol=/" ];
  };
}