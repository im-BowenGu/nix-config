{ pkgs, ... }:

{
  fonts.packages = with pkgs; [
    font-awesome
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    fira-sans
    roboto
    material-design-icons
    material-symbols
    liberation_ttf
    google-fonts
  ];
}
