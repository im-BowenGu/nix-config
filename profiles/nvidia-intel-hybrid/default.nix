{host, ...}: let
  inherit (import ../../hosts/${host}/variables.nix) stylixImage;
in {
  imports = [
    ../../hosts/${host}
    ../../modules/drivers
    ../../modules/core
    inputs.stylix.nixosModules.stylix
  ];

  drivers.intel.enable = true;
  drivers.nvidia-prime.enable = true;
  drivers.nvidia-prime.intelBusID = "PCI:0:2:0";
  drivers.nvidia-prime.nvidiaBusID = "PCI:2:0:0";

  stylix = {
    enable = true;
    image = stylixImage;
    polarity = "dark";
    opacity.terminal = 1.0;
    cursor = {
      package = pkgs.nordzy-cursor-theme;
      name = "Nordzy-cursors";
      size = 24;
    };
    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrains Mono";
      };
      sansSerif = {
        package = pkgs.montserrat;
        name = "Montserrat";
      };
      serif = {
        package = pkgs.montserrat;
        name = "Montserrat";
      };
      sizes = {
        applications = 12;
        terminal = 15;
        desktop = 11;
        popups = 12;
      };
    };
  };

  vm.guest-services.enable = false;
}