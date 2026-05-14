{
  lib,
  pkgs,
  config,
  ...
}:
with lib; let
  cfg = config.drivers.nvidia-prime;
in {
  options.drivers.nvidia-prime = {
    enable = mkEnableOption "Enable Nvidia Prime Hybrid GPU Offload";
    intelBusID = mkOption {
      type = types.str;
      default = "PCI:1:0:0";
    };
    nvidiaBusID = mkOption {
      type = types.str;
      default = "PCI:0:2:0";
    };
  };

  config = mkIf cfg.enable {
    services.xserver.videoDrivers = [ "nvidia" ];

    boot.blacklistedKernelModules = [ "nouveau" ];

    boot.kernelModules = [ "nvidia_uvm" "nvidia_modeset" "nvidia_drm" "nvidia" ];

    boot.kernelParams = [
      "nvidia-drm.modeset=1"
      "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
    ];

    hardware.nvidia = {
      package = config.boot.kernelPackages.nvidiaPackages.beta;
      modesetting.enable = true;
      nvidiaSettings = true;
      nvidiaPersistenced = true;
      open = true;
      powerManagement.enable = true;
      powerManagement.finegrained = true;

      prime = {
        offload = {
          enable = true;
          enableOffloadCmd = true;
          offloadCmdMainProgram = "prime-run";
        };
        intelBusId = cfg.intelBusID;
        nvidiaBusId = cfg.nvidiaBusID;
      };
    };

    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    environment.systemPackages = with pkgs; [
      cudaPackages.cudatoolkit
      vulkan-tools
      vulkan-loader
      vulkan-validation-layers
      mesa
      ocl-icd
      nvtopPackages.nvidia
    ];

    environment.sessionVariables = {
      CUDA_PATH = "${pkgs.cudaPackages.cudatoolkit}";
    };
  };
}