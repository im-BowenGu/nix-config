{ pkgs, lib, ... }:

{
  programs.kitty = {
    enable = true;
    settings = {
      confirm_os_window_close = 0;
      background_opacity = lib.mkForce "0.85";
      font_size = 8;
    };
  };
}
