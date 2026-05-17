{ pkgs, inputs, ... }:

{
  imports = [inputs.home-manager.nixosModules.home-manager];

  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    backupFileExtension = "backup";
    extraSpecialArgs = { inherit inputs; };
    users.secret-star = {
      imports = [
        ../../modules/home
      ];
      home = {
        username = "secret-star";
        homeDirectory = "/home/secret-star";
        stateVersion = "25.11";
      };
    };
  };

  users.mutableUsers = true;
  users.users.secret-star = {
    isNormalUser = true;
    description = "secret-star";
    extraGroups = [
      "networkmanager"
      "wheel"
      "input"
      "video"
      "waydroid"
      "libvirtd"
    ];
  };

  system.stateVersion = "25.11";
}
