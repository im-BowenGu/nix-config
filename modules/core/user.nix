{
  users.users.my = {
    isNormalUser = true;
    description = "My";
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