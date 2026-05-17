{ pkgs, lib, config, ... }:

{
  programs.bash = {
    enable = true;
    shellAliases = {
      ls = "eza --icons=auto";
      grep = "rg";
      sudo = "doas";

      cat = "bat --style=plain";
      find = "fd";
      df = "duf";
      du = "dust";
      ps = "procs";

      cd = "z";
    };
    initExtra = ''
      eval "$(oh-my-posh init bash --config ~/.config/oh-my-posh/night-owl.omp.json)"
      fastfetch
    '';
  };

  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
  };

  home.packages = with pkgs; [
    fastfetch
    oh-my-posh
    kdePackages.dolphin

    eza
    ripgrep
    bat
    fd
    duf
    dust
    procs

    fzf
    yazi

    comma
  ];

  xdg.configFile."oh-my-posh/night-owl.omp.json" = {
    source = ./dotfiles/oh-my-posh/night-owl.omp.json;
  };
}
