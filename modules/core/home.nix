{ pkgs, inputs, ... }:

{
  imports = [
    ./noctalia.nix
  ];

  home.packages = with pkgs; [
    inputs.awww.packages.${pkgs.stdenv.hostPlatform.system}.awww
  ];
}