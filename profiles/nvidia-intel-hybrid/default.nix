{host, inputs, pkgs, config, ...}: let
  vars = import ../../hosts/${host}/variables.nix;
in {
  imports = [
    ../../hosts/${host}
    ../../modules/drivers
    ../../modules/core
  ];

  drivers.intel.enable = true;
  drivers.nvidia-prime.enable = true;
  drivers.nvidia-prime.intelBusID = "PCI:0:2:0";
  drivers.nvidia-prime.nvidiaBusID = "PCI:2:0:0";

  stylix.image = vars.stylixImage;
}
