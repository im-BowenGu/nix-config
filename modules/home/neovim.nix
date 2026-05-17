{ pkgs, inputs, ... }:

{
  imports = [
    inputs.lazyvim-nix.homeManagerModules.default
  ];

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  programs.lazyvim = {
    enable = true;

    extras = {
      lang.nix.enable = true;
      lang.python = {
        enable = true;
        installDependencies = true;
        installRuntimeDependencies = true;
      };
      lang.go = {
        enable = true;
        installDependencies = true;
        installRuntimeDependencies = true;
      };
      lang.typescript = {
        enable = true;
        installDependencies = true;
        installRuntimeDependencies = true;
      };
      lang.json.enable = true;
      lang.markdown.enable = true;
      lang.yaml.enable = true;
      editor.leap.enable = true;
    };

    extraPackages = with pkgs; [
      nixd
      alejandra
    ];

    plugins = {
      colorscheme = ''
        return {
          "catppuccin/nvim",
          name = "catppuccin",
          opts = {
            flavour = "mocha",
            transparent_background = true,
          },
        }
      '';
    };

    config = {
      options = ''
        vim.opt.relativenumber = true
        vim.opt.number = true
        vim.opt.wrap = false
        vim.opt.termguicolors = true
      '';
    };
  };
}
