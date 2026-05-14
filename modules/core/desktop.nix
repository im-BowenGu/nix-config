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
  home-manager.users.secret-star = {
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
    ydotool
    hyprshot
    hyprpicker
    hypridle
    swaylock
    wlogout
    brightnessctl
    playerctl
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
      systemd = {
        enable = true;
        enableXdgAutostart = true;
        variables = [ "--all" ];
      };

      settings = {
        "$mainMod" = "SUPER";
        "$terminal" = "kitty";
        "$fileManager" = "dolphin";
        "$browser" = "librewolf";

        monitor = vars.extraMonitorSettings;

        env = [
          "NIXOS_OZONE_WL, 1"
          "XDG_CURRENT_DESKTOP, Hyprland"
          "XDG_SESSION_TYPE, wayland"
          "XDG_SESSION_DESKTOP, Hyprland"
          "GDK_BACKEND, wayland, x11"
          "CLUTTER_BACKEND, wayland"
          "QT_QPA_PLATFORM,wayland;xcb"
          "QT_WAYLAND_DISABLE_WINDOWDECORATION, 1"
          "QT_AUTO_SCREEN_SCALE_FACTOR, 1"
          "MOZ_ENABLE_WAYLAND, 1"
          "ELECTRON_OZONE_PLATFORM_HINT,wayland"
          "GDK_SCALE,1"
          "QT_SCALE_FACTOR,1"
          "EDITOR,nvim"
          "TERMINAL,kitty"
          "XCURSOR_SIZE,24"
          "HYPRCURSOR_SIZE,24"
          "XDG_MENU_PREFIX,plasma-"
        ];

        exec-once = [
          "killall -q waybar"
          "pkill waybar"
          "killall -q swaync"
          "pkill swaync"
          "noctalia-shell &"
          "wl-paste --type text --watch cliphist store"
          "wl-paste --type image --watch cliphist store"
          "dbus-update-activation-environment --all --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
          "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
          "systemctl --user start hyprpolkitagent"
          "hyprctl setcursor Nordzy-cursors 24"
          "awww-daemon &"
          "sleep 1 && awww img ~/.config/hypr/wallpaper.png &"
        ];

        input = {
          kb_layout = "us";
          kb_options = [
            "grp:alt_caps_toggle"
            "caps:super"
          ];
          numlock_by_default = true;
          repeat_delay = 300;
          follow_mouse = 1;
          float_switch_override_focus = 0;
          sensitivity = 0;
          touchpad = {
            natural_scroll = true;
            disable_while_typing = true;
            scroll_factor = 0.8;
            tap-to-click = true;
            clickfinger_behavior = true;
          };
        };

        device = [
          { name = "gxtp5100:00-27c6:01eb-touchpad"; sensitivity = 0.1; enabled = true; }
          { name = "gxtp5100:00-27c6:01eb-mouse"; sensitivity = 0.1; enabled = true; }
        ];

        general = {
          layout = "dwindle";
          gaps_in = 6;
          gaps_out = 8;
          gaps_workspaces = 50;
          border_size = 2;
          resize_on_border = true;
          allow_tearing = true;
          "col.active_border" = "rgba(bf00ffee) rgba(d56ab1ee) 45deg";
          "col.inactive_border" = "rgba(53433fff)";
        };

        misc = {
          layers_hog_keyboard_focus = true;
          initial_workspace_tracking = 0;
          mouse_move_enables_dpms = true;
          key_press_enables_dpms = true;
          disable_hyprland_logo = true;
          disable_splash_rendering = true;
          enable_swallow = false;
          vrr = 2;
          enable_anr_dialog = true;
          anr_missed_pings = 15;
        };

        dwindle = {
          pseudotile = false;
          preserve_split = true;
          smart_resizing = true;
          use_active_for_splits = true;
          smart_split = false;
          default_split_ratio = 1.0;
          split_bias = 0;
          precise_mouse_move = false;
          special_scale_factor = 0.8;
        };

        decoration = {
          rounding = 10;
          active_opacity = 1.0;
          inactive_opacity = 0.9;
          dim_inactive = true;
          dim_strength = 0.3;
          blur = {
            enabled = true;
            size = 5;
            passes = 3;
            ignore_opacity = false;
            new_optimizations = true;
            xray = true;
          };
          shadow = {
            enabled = true;
            range = 4;
            render_power = 3;
            color = "rgba(1a1a1aee)";
          };
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

        gestures = {
          gesture = [ "3, horizontal, workspace" ];
          workspace_swipe_distance = 500;
          workspace_swipe_invert = true;
          workspace_swipe_min_speed_to_force = 30;
          workspace_swipe_cancel_ratio = 0.5;
          workspace_swipe_create_new = true;
          workspace_swipe_forever = true;
        };

        cursor = {
          sync_gsettings_theme = true;
          no_hardware_cursors = 2;
          enable_hyprcursor = false;
          warp_on_change_workspace = 2;
          no_warps = true;
        };

        render = {
          direct_scanout = 0;
        };

        master = {
          new_status = "slave";
          new_on_top = false;
          new_on_active = "none";
          orientation = "left";
          mfact = 0.55;
          slave_count_for_center_master = 2;
          center_master_fallback = "left";
          smart_resizing = true;
          drop_at_cursor = true;
          always_keep_position = false;
        };

        windowrule = [
          "float on, match:class ^pavucontrol$"
          "float on, match:class ^blueman-manager$"
          "float on, match:class ^nm-connection-editor$"
          "float on, match:class ^qalculate-gtk$"
          "float on, match:title ^Open File.*$"
          "immediate on, match:class ^steam_app.*$"
          "float, match:class ^floating$"
          "size 600 400, match:class ^floating$"
          "center, match:title ^Open File.*$"
        ];

        bind = [
          # ============= LAUNCHER =============
          "$mainMod CONTROL, Return, exec, fuzzel"
          # ============= TERMINALS =============
          "$mainMod, Return, exec, kitty"
          "$mainMod SHIFT, T, exec, kitty --class dropdown"
          # ============= APPLICATION LAUNCHERS =============
          "$mainMod, B, exec, $browser"
          "$mainMod, E, exec, $fileManager"
          "$mainMod, O, exec, obs"
          # ============= WINDOW MANAGEMENT =============
          "$mainMod, Q, killactive"
          "$mainMod, P, pseudo"
          "$mainMod SHIFT, I, layoutmsg, togglesplit"
          "$mainMod, F, fullscreen, 0"
          "$mainMod, T, togglefloating"
          # ============= LAYOUTS =============
          "$mainMod ALT, L, exec, hyprland-change-layout toggle"
          "$mainMod ALT, 1, exec, hyprland-change-layout dwindle"
          "$mainMod ALT, 2, exec, hyprland-change-layout master"
          "$mainMod ALT, 3, exec, hyprland-change-layout monocle"
          # ============= WINDOW MOVEMENT (ARROW KEYS) =============
          "$mainMod SHIFT, left, movewindow, l"
          "$mainMod SHIFT, right, movewindow, r"
          "$mainMod SHIFT, up, movewindow, u"
          "$mainMod SHIFT, down, movewindow, d"
          # ============= WINDOW MOVEMENT (VI STYLE) =============
          "$mainMod SHIFT, h, movewindow, l"
          "$mainMod SHIFT, l, movewindow, r"
          "$mainMod SHIFT, k, movewindow, u"
          "$mainMod SHIFT, j, movewindow, d"
          # ============= WINDOW SWAPPING (ARROW KEYS) =============
          "$mainMod ALT, left, swapwindow, l"
          "$mainMod ALT, right, swapwindow, r"
          "$mainMod ALT, up, swapwindow, u"
          "$mainMod ALT, down, swapwindow, d"
          # ============= FOCUS MOVEMENT (ARROW KEYS) =============
          "$mainMod, left, movefocus, l"
          "$mainMod, right, movefocus, r"
          "$mainMod, up, movefocus, u"
          "$mainMod, down, movefocus, d"
          # ============= FOCUS MOVEMENT (VI STYLE) =============
          "$mainMod, h, movefocus, l"
          "$mainMod, l, movefocus, r"
          "$mainMod, k, movefocus, u"
          "$mainMod, j, movefocus, d"
          # ============= WORKSPACE SWITCHING (1-10) =============
          "$mainMod, 1, workspace, 1"
          "$mainMod, 2, workspace, 2"
          "$mainMod, 3, workspace, 3"
          "$mainMod, 4, workspace, 4"
          "$mainMod, 5, workspace, 5"
          "$mainMod, 6, workspace, 6"
          "$mainMod, 7, workspace, 7"
          "$mainMod, 8, workspace, 8"
          "$mainMod, 9, workspace, 9"
          # ============= MOVE WINDOW TO WORKSPACE =============
          "$mainMod SHIFT, SPACE, movetoworkspace, special"
          "$mainMod, SPACE, togglespecialworkspace"
          "$mainMod SHIFT, 1, movetoworkspace, 1"
          "$mainMod SHIFT, 2, movetoworkspace, 2"
          "$mainMod SHIFT, 3, movetoworkspace, 3"
          "$mainMod SHIFT, 4, movetoworkspace, 4"
          "$mainMod SHIFT, 5, movetoworkspace, 5"
          "$mainMod SHIFT, 6, movetoworkspace, 6"
          "$mainMod SHIFT, 7, movetoworkspace, 7"
          "$mainMod SHIFT, 8, movetoworkspace, 8"
          "$mainMod SHIFT, 9, movetoworkspace, 9"
          # ============= WORKSPACE NAVIGATION =============
          "$mainMod CONTROL, right, workspace, e+1"
          "$mainMod CONTROL, left, workspace, e-1"
          "$mainMod, mouse_down, workspace, e+1"
          "$mainMod, mouse_up, workspace, e-1"
          # ============= CLIPPBOARD & SYSTEM =============
          "$mainMod, V, exec, cliphist list | rofi -dmenu | cliphist decode | wl-copy"
          "$mainMod CONTROL, Q, exit"
          "$mainMod SHIFT, Q, exec, wlogout"
          "$mainMod SHIFT, W, exec, waypaper --random"
          "$mainMod CONTROL, R, exec, hyprctl reload"
          # ============= SCREENSHOTS =============
          "SUPER SHIFT, P, exec, XDG_CURRENT_DESKTOP=sway flameshot gui"
          "$mainMod CONTROL, S, exec, hyprshot -m output -o $HOME/Pictures/ScreenShots"
          "$mainMod SHIFT, S, exec, hyprshot -m window -o $HOME/Pictures/ScreenShots"
          "$mainMod ALT, S, exec, hyprshot -m region -o $HOME/Pictures/ScreenShots"
        ];

        bindle = [
          # ============= MEDIA & HARDWARE CONTROLS =============
          ",XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
          ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
          ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
          ",XF86AudioPlay, exec, playerctl play-pause"
          ",XF86AudioPause, exec, playerctl play-pause"
          ",XF86AudioNext, exec, playerctl next"
          ",XF86AudioPrev, exec, playerctl previous"
          ",XF86MonBrightnessDown, exec, brightnessctl set 5%-"
          ",XF86MonBrightnessUp, exec, brightnessctl set +5%"
        ];

        bindm = [
          "$mainMod, mouse:272, movewindow"
          "$mainMod, mouse:273, resizewindow"
        ];
      };

      extraConfig = ''
        xwayland {
          force_zero_scaling = true
        }
      '';
    };
  };

  programs.kitty.enable = true;

  imports = [
    inputs.noctalia.homeModules.default
  ];
}