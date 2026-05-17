{ pkgs, ... }:

{
  security.doas.enable = true;
  security.doas.extraRules = [{
    groups = [ "wheel" ];
    setEnv = [
      "PATH"
      "NIX_PATH"
      "NIXPKGS_ALLOW_UNFREE"
      "TERMINFO"
      "EDITOR"
      "VISUAL"
      "XDG_CONFIG_HOME"
      "XDG_DATA_HOME"
      "XDG_CACHE_HOME"
      "XDG_RUNTIME_DIR"
    ];
    keepEnv = true;
    persist = true;
  }];

  security.sudo.enable = false;
  security.wrappers.sudo = {
    source = "${pkgs.doas}/bin/doas";
    owner = "root";
    group = "root";
    setuid = true;
  };

  services.fprintd.enable = true;

  security.pam.services = {
    sudo.fprintAuth = true;
    login.fprintAuth = true;
    doas.fprintAuth = true;
    sddm.fprintAuth = true;
  };
}