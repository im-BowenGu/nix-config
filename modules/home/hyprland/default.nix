{ pkgs, ... }: {
  imports = [
    ./env.nix
    ./hypridle.nix
    ./hyprlock.nix
  ];

  home.packages = [ pkgs.alsa-utils ];

  xdg.configFile."MacStartupChime.ogg.wav".source = ./MacStartupChime.ogg.wav;
}
