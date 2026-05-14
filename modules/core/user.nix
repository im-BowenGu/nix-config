{
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