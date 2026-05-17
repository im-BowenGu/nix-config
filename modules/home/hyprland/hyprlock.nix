{ pkgs, ... }:

{
  home.packages = with pkgs; [
    hyprlock
    socat
  ];
}
