{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/hardware/cpu/intel-npu.nix")
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "nvme" "usb_storage" "sd_mod" "sdhci_pci" ];

  boot.initrd.kernelModules = [
    "i2c_hid_acpi"
    "i2c_designware_pci"
    "i2c_designware_platform"
    "intel_lpss_pci"
  ];

  boot.kernelModules = [ "kvm-intel" "i2c_dev" ];

  boot.kernelParams = [
    "pinctrl_intel.strict_gpio_check=0"
    "i2c_designware.force_load=1"
    "acpi_enforce_resources=lax"
    "i2c_hid.polling_mode=0"
  ];

  boot.extraModprobeConfig = ''
    options snd-intel-dspcfg dsp_driver=3
    options snd-hda-intel dmic_detect=0
  '';

  hardware.enableAllFirmware = true;
  hardware.enableRedistributableFirmware = true;

  hardware.firmware = [
    pkgs.alsa-firmware
    pkgs.sof-firmware
    (pkgs.runCommand "cs35l56-firmware" {
        compressFirmware = false;
      } ''
      mkdir -p $out/lib/firmware/cirrus
      SRC=${./../../modules/audio-fix}
      cp "$SRC/CS35L56_Rev3.13.0.wmfw" $out/lib/firmware/cirrus/cs35l56-b0-dsp1-misc-17aa391e.wmfw
      cp "$SRC/CS35L56_Rev3.13.0.wmfw" $out/lib/firmware/cirrus/cs35l56-b0-dsp1-misc-17AA391E.wmfw
      cp "$SRC/17AA391E_250321_V0_A0-init.bin" $out/lib/firmware/cirrus/cs35l56-b0-dsp1-misc-17aa391e-amp1.bin
      cp "$SRC/17AA391E_250321_V0_A0-init.bin" $out/lib/firmware/cirrus/cs35l56-b0-dsp1-misc-17AA391E-AMP1.bin
      cp "$SRC/17AA391E_250321_V0_A0-init.bin" $out/lib/firmware/cirrus/cs35l56-b0-dsp1-misc-17aa391e-spkid0-amp1.bin
      cp "$SRC/17AA391E_250321_V0_A1-init.bin" $out/lib/firmware/cirrus/cs35l56-b0-dsp1-misc-17aa391e-amp2.bin
      cp "$SRC/17AA391E_250321_V0_A1-init.bin" $out/lib/firmware/cirrus/cs35l56-b0-dsp1-misc-17AA391E-AMP2.bin
      cp "$SRC/17AA391E_250321_V0_A1-init.bin" $out/lib/firmware/cirrus/cs35l56-b0-dsp1-misc-17aa391e-spkid0-amp2.bin
      '')
  ];

  environment.systemPackages = with pkgs; [
    sof-firmware
    alsa-firmware
    alsa-utils
    libinput
  ];

  environment.etc."libinput/local-overrides.quirks".text = ''
    [Goodix Touchpad Fixes]
    MatchUdevType=touchpad
    MatchVendor=0x27C6
    MatchProduct=0x01EB
    AttrPressureRange=10:5
    AttrEventCode=-ABS_MT_PRESSURE
  '';

  fileSystems."/" = { device = "/dev/disk/by-uuid/00ef0c2c-19a4-4e6e-92b8-e11b8235e2ea"; fsType = "btrfs"; options = [ "subvol=@" ]; };
  fileSystems."/home" = { device = "/dev/disk/by-uuid/00ef0c2c-19a4-4e6e-92b8-e11b8235e2ea"; fsType = "btrfs"; options = [ "subvol=@home" ]; };
  fileSystems."/boot" = { device = "/dev/disk/by-uuid/7C08-6B3F"; fsType = "vfat"; options = [ "fmask=0077" "dmask=0077" ]; };
  fileSystems."/data" = {
    device = "/dev/disk/by-uuid/94b6bb2e-8d32-400d-98a0-988ae9dc6a1d";
    fsType = "btrfs";
    options = [ "rw" "relatime" "ssd" "discard=async" "space_cache=v2" "subvol=/" ];
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.npu.enable = true;
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}