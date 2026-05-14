{ config, lib, pkgs, inputs, ... }:

let
  vars = import ../../hosts/thinkbook-16p/variables.nix;
in
{
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  programs.uwsm = {
    enable = true;
    waylandCompositors.hyprland = {
      prettyName = "Hyprland";
      comment = "Hyprland managed by UWSM";
      binPath = "/run/current-system/sw/bin/Hyprland";
    };
  };

  services.gnome.gnome-keyring.enable = true;
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk pkgs.xdg-desktop-portal-hyprland ];
  };

  programs.nm-applet.enable = true;
  services.power-profiles-daemon.enable = true;
  services.gvfs.enable = true;
  services.tumbler.enable = true;

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

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.my = {
    home.stateVersion = "25.11";
    imports = [
      inputs.home-manager.nixosModules.home-manager
      ./home.nix
    ];
  };

  environment.systemPackages = with pkgs; [
    libnotify
    qt5.qtwayland
    qt6.qtwayland
    qt6.qtsvg
    qt6.qtmultimedia
    qt6.qtvirtualkeyboard
    gnome-themes-extra
    networkmanagerapplet
    imagemagick
    hyprpolkitagent
    hyprsunset
    grimblast
    tesseract
    matugen
    fprintd
    cliphist
    wl-clipboard
    nordzy-cursor-theme
    awww
    fuzzel
    kdePackages.qtstyleplugin-kvantum
    kdePackages.breeze-icons
    (python3.withPackages (ps: with ps; [ pip pygobject3 screeninfo ]))
    inputs.awww.packages.${pkgs.stdenv.hostPlatform.system}.awww
  ];

  home = {
    stateVersion = "25.11";

    gtk = {
      enable = true;
      theme = {
        name = "Adwaita-dark";
        package = pkgs.gnome-themes-extra;
      };
      cursorTheme = {
        name = "Nordzy-cursors";
        package = pkgs.nordzy-cursor-theme;
      };
    };

    pointerCursor = {
      gtk.enable = true;
      package = pkgs.nordzy-cursor-theme;
      name = "Nordzy-cursors";
      size = 24;
    };

    programs.kitty.settings = {
      confirm_os_window_close = 0;
    };

    wayland.windowManager.hyprland = {
      enable = true;
      systemd.enable = true;
      settings = {
        "$mainMod" = "SUPER";
        "$terminal" = "kitty";
        "$fileManager" = "dolphin";
        "$browser" = "librewolf";

        monitor = vars.extraMonitorSettings;

        env = [
          "XDG_CURRENT_DESKTOP,Hyprland"
          "XDG_SESSION_TYPE,wayland"
          "XDG_SESSION_DESKTOP,Hyprland"
          "XCURSOR_SIZE,24"
          "HYPRCURSOR_SIZE,24"
          "QT_QPA_PLATFORM,wayland;xcb"
          "QT_QPA_PLATFORMTHEME,kde"
          "MOZ_ENABLE_WAYLAND,1"
          "XMODIFIERS,@im=fcitx"
          "QT_IM_MODULE,fcitx"
          "GTK_IM_MODULE,fcitx"
        ];

        exec-once = [
          "${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent"
          "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
          "fcitx5 -d"
          "wl-paste --watch cliphist store"
          "hyprctl setcursor Nordzy-cursors 24"
          "awww-daemon &"
        ];

        input = {
          kb_layout = "us";
          numlock_by_default = true;
          follow_mouse = 1;
          sensitivity = 0;
          touchpad = {
            natural_scroll = true;
            "tap-to-click" = true;
            disable_while_typing = true;
            clickfinger_behavior = true;
          };
        };

        device = [
          { name = "gxtp5100:00-27c6:01eb-touchpad"; sensitivity = 0.1; enabled = true; }
          { name = "gxtp5100:00-27c6:01eb-mouse"; sensitivity = 0.1; enabled = true; }
        ];

        general = {
          layout = "dwindle";
          gaps_in = 4;
          gaps_out = 5;
          gaps_workspaces = 50;
          border_size = 4;
          resize_on_border = true;
          allow_tearing = true;
        };

        decoration = {
          rounding = 18;
          active_opacity = 1.0;
          inactive_opacity = 0.9;
          dim_inactive = true;
          dim_strength = 0.3;
          blur = { enabled = true; size = 10; passes = 3; xray = true; };
          shadow = { enabled = true; range = 32; };
        };

        animations = {
          enabled = true;
          bezier = "myBezier, 0.05, 0.9, 0.1, 1.1";
          animation = [
            "windows, 1, 7, myBezier"
            "windowsOut, 1, 7, default, popin 80%"
            "border, 1, 10, default"
            "fade, 1, 7, default"
            "workspaces, 1, 6, default"
          ];
        };

        windowrule = [
          "float on, match:class ^pavucontrol$"
          "float on, match:class ^blueman-manager$"
          "float on, match:class ^nm-connection-editor$"
          "float on, match:class ^qalculate-gtk$"
          "float on, match:title ^Open File.*$"
          "immediate on, match:class ^steam_app.*$"
        ];

        bind = [
          "$mainMod, RETURN, exec, kitty"
          "$mainMod, B, exec, $browser"
          "$mainMod, E, exec, $fileManager"
          "$mainMod CONTROL, RETURN, exec, fuzzel"
          "$mainMod, Q, killactive"
          "$mainMod, F, fullscreen, 0"
          "$mainMod, T, togglefloating"
          "$mainMod, J, togglesplit"
          "$mainMod, left, movefocus, l"
          "$mainMod, right, movefocus, r"
          "$mainMod, up, movefocus, u"
          "$mainMod, down, movefocus, d"
          "$mainMod, V, exec, cliphist list | rofi -dmenu | cliphist decode | wl-copy"
          "$mainMod CONTROL, Q, exec, wlogout"
          "$mainMod SHIFT, W, exec, waypaper --random"
          "$mainMod CONTROL, R, exec, hyprctl reload"
          "$mainMod, 1, workspace, 1"
          "$mainMod, 2, workspace, 2"
          "$mainMod, 3, workspace, 3"
          "$mainMod, 4, workspace, 4"
          "$mainMod, 5, workspace, 5"
          "$mainMod, 6, workspace, 6"
          "$mainMod, 7, workspace, 7"
          "$mainMod, 8, workspace, 8"
          "$mainMod, 9, workspace, 9"
          "$mainMod SHIFT, 1, movetoworkspace, 1"
          "$mainMod SHIFT, 2, movetoworkspace, 2"
          "$mainMod SHIFT, 3, movetoworkspace, 3"
          "$mainMod SHIFT, 4, movetoworkspace, 4"
          "$mainMod SHIFT, 5, movetoworkspace, 5"
          "$mainMod SHIFT, 6, movetoworkspace, 6"
          "$mainMod SHIFT, 7, movetoworkspace, 7"
          "$mainMod SHIFT, 8, movetoworkspace, 8"
          "$mainMod SHIFT, 9, movetoworkspace, 9"
          "SUPER SHIFT, P, exec, XDG_CURRENT_DESKTOP=sway flameshot gui"
        ];

        bindle = [
          ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
          ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ];

        bindm = [
          "$mainMod, mouse:272, movewindow"
          "$mainMod, mouse:273, resizewindow"
        ];
      };

      extraConfig = ''
        gesture = 3, horizontal, workspace
        gestures {
          workspace_swipe_distance = 700
          workspace_swipe_cancel_ratio = 0.2
          workspace_swipe_min_speed_to_force = 5
          workspace_swipe_direction_lock = true
          workspace_swipe_create_new = true
        }
      '';
    };
  };

  programs.kitty.enable = true;

  imports = [
    inputs.noctalia.homeModules.default
  ];
}