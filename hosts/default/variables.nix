{
  gitUsername = "im-BowenGu";
  gitEmail = "bowen.gu@abingdon.org.uk";

  displayManager = "sddm";

  barChoice = "noctalia";

  browser = "librewolf";

  terminal = "kitty";

  keyboardLayout = "us";
  keyboardVariant = "";
  consoleKeyMap = "us";

  extraMonitorSettings = "monitor = eDP-1, 3200x2000@165, 0x0, 2";

  stylixImage = ../wallpapers/wallpaper.png;

  stylixCursor = {
    package = pkgs.nordzy-cursor-theme;
    name = "Nordzy-cursors";
    size = 24;
  };

  enableNFS = false;
  printEnable = false;

  thunarEnable = true;

  barToggle = true;
  waybarChoice = ../modules/home/waybar/waybar-mangowc-jak-catppuccin.nix;
  animChoice = ../modules/home/hyprland/animations-ml4w-classic.nix;
}