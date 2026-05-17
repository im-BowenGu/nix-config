{ pkgs, lib, ... }:

let
  base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";

  kvantumTheme = pkgs.runCommand "base16-kvantum" {
    buildInputs = [ (pkgs.python3.withPackages (ps: [ ps.pyyaml ])) ];
  } ''
    python3 ${./scripts/generate-kvantum.py} ${base16Scheme} "$out" "base16-kvantum"
  '';

  gentlySrc = pkgs.fetchFromGitHub {
    owner = "L4ki";
    repo = "Gently";
    rev = "master";
    sha256 = "sha256-4oK/qvGsCL8EalisVHOjh1P5mLRZtRoIrgezbvzqZQw=";
  };

  gentlyTheme = pkgs.runCommand "gently-plasma-theme" {} ''
    mkdir -p $out/share/plasma/desktoptheme
    cp -r ${gentlySrc}/Gently-Plasma/Gently $out/share/plasma/desktoptheme/Gently

    mkdir -p $out/share/color-schemes
    cp ${gentlySrc}/Gently-Plasma/Gently/colors $out/share/color-schemes/Gently.colors
  '';

in {
  qt = {
    enable = true;
    platformTheme.name = lib.mkForce "kde";
    style = {
      name = lib.mkForce "kvantum";
      package = lib.mkForce pkgs.kdePackages.qtstyleplugin-kvantum;
    };
  };

  xdg.configFile."Kvantum/kvantum.kvconfig".text = ''
    [General]
    theme=base16-kvantum
  '';

  xdg.configFile."Kvantum/base16-kvantum" = {
    source = kvantumTheme;
    recursive = true;
  };

  xdg.dataFile."plasma/desktoptheme/Gently" = {
    source = "${gentlyTheme}/share/plasma/desktoptheme/Gently";
    recursive = true;
  };

  xdg.dataFile."color-schemes/Gently.colors" = {
    source = "${gentlyTheme}/share/color-schemes/Gently.colors";
  };

  xdg.configFile."kdeglobals".text = ''
    [General]
    ColorScheme=Gently

    [Icons]
    Theme=breeze-dark

    [KDE]
    widgetStyle=kvantum
  '';

  xdg.configFile."plasmarc".text = ''
    [Theme]
    name=Gently
  '';
}
