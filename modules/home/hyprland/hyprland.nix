{ lib, pkgs, ... }:
  let
  compactWorkspaces = pkgs.writeShellScriptBin "compact-workspaces" ''
    initial_focused=$(${pkgs.hyprland}/bin/hyprctl activeworkspace -j | ${pkgs.jq}/bin/jq -r '.id')
    new_focused=$initial_focused

    workspaces=$(${pkgs.hyprland}/bin/hyprctl workspaces -j | ${pkgs.jq}/bin/jq '.[] | .id' | sort -n | grep -v '^-')
    expected=1

    for ws in $workspaces; do
        if [ "$ws" -gt "$expected" ]; then
            windows=$(${pkgs.hyprland}/bin/hyprctl clients -j | ${pkgs.jq}/bin/jq -r ".[] | select(.workspace.id == $ws) | .address")
            
            for win in $windows; do
                ${pkgs.hyprland}/bin/hyprctl dispatch movetoworkspacesilent "$expected,address:$win"
            done
            
            if [ "$ws" -eq "$initial_focused" ]; then
                new_focused=$expected
            fi
            
            expected=$((expected + 1))
        else
            expected=$((ws + 1))
        fi
    done

    if [ "$initial_focused" -ne "$new_focused" ]; then
        ${pkgs.hyprland}/bin/hyprctl dispatch workspace "$new_focused"
    fi
  '';
  in
  {
  home.packages = [ 
    compactWorkspaces
    pkgs.jq 
  ];
  wayland.windowManager.hyprland = {
    enable = true;
    configType = "hyprlang";
    settings = {
      "$terminal" = "kitty";
      "$fileManager" = "dolphin";
      "$browser" = "flatpak run io.gitlab.librewolf-community";
      "$menu" = "fuzzel";
      "$mainMod" = "SUPER";

      monitor = "eDP-1, 3200x2000@165, auto, 2";

      exec-once = [
        "nm-applet"
        "noctalia-shell"
        "hyprlock && pw-play /home/secret-star/.config/sound.wav"
	"socat - UNIX-CONNECT:\$XDG_RUNTIME_DIR/hypr/\$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock | grep --line-buffered 'unlockactive' | while read -r line; do pw-play /home/secret-star/.config/sound.wav & done"
	"hyprpolkitagent"
      ];

      env = [
        "XCURSOR_SIZE,24"
        "HYPRCURSOR_SIZE,24"
        "NIXOS_OZONE_WL, 1"
        "NIXPKGS_ALLOW_UNFREE, 1"
        "XDG_CURRENT_DESKTOP, Hyprland"
        "XDG_SESSION_TYPE, wayland"
        "XDG_SESSION_DESKTOP, Hyprland"
        "GDK_BACKEND, wayland, x11"
        "QT_QPA_PLATFORM=wayland;xcb"
        "QT_WAYLAND_DISABLE_WINDOWDECORATION, 1"
        "QT_AUTO_SCREEN_SCALE_FACTOR, 1"
        "SDL_VIDEODRIVER, x11"
        "MOZ_ENABLE_WAYLAND, 1"
        "ELECTRON_OZONE_PLATFORM_HINT,wayland"
        "GDK_SCALE,1"
        "QT_SCALE_FACTOR,1"
        "TERMINAL,kitty"
        "XDG_TERMINAL_EMULATOR,kitty"
      ];

      general = {
        gaps_in = 5;
        gaps_out = 20;
        border_size = 2;
      "col.active_border" = lib.mkForce "rgba(33ccffee) rgba(00ff99ee) 45deg";
      "col.inactive_border" = lib.mkForce "rgba(595959aa)";
        resize_on_border = true;
        allow_tearing = false;
        layout = "dwindle";
      };

      decoration = {
        rounding = 10;
        rounding_power = 2;
        active_opacity = 1.0;
        inactive_opacity = 1.0;
        shadow = {
          enabled = true;
          range = 4;
          render_power = 3;
        };
        blur = {
          enabled = true;
          size = 3;
          passes = 1;
          vibrancy = 0.1696;
        };
      };

      animations = {
        enabled = true;
        bezier = [
          "wind, 0.05, 0.9, 0.1, 1.05"
          "winIn, 0.1, 1.1, 0.1, 1.1"
          "winOut, 0.3, -0.3, 0, 1"
          "liner, 1, 1, 1, 1"
        ];
        animation = [
          "windows, 1, 6, wind, slide"
          "windowsIn, 1, 6, winIn, slide"
          "windowsOut, 1, 5, winOut, slide"
          "windowsMove, 1, 5, wind, slide"
          "border, 1, 1, liner"
          "borderangle, 1, 30, liner, loop"
          "fade, 1, 10, default"
          "workspaces, 1, 5, wind"
        ];
      };

      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      master.new_status = "master";

      misc = {
        force_default_wallpaper = -1;
      };

      # 3-finger horizontal swipe for workspace switching
      gesture = "3, horizontal, workspace";

      input = {
        kb_layout = "us";
        kb_variant = "";
        kb_model = "";
        kb_options = "";
        kb_rules = "";
        follow_mouse = 1;
        sensitivity = 0;
        touchpad.natural_scroll = false;
      };

      bind = [
        "$mainMod SHIFT, C, exec, compact-workspaces"
        "SUPER, Q, killactive,"
        "CTRL SUPER, Q, exec, wlogout"
        "SUPER, Return, exec, $terminal"
	"SUPER, L, exec, hyprlock && pw-play /home/secret-star/.config/sound.wav"
        "SUPER, B, exec, $browser"
        "SUPER, E, exec, $fileManager"
        "SUPER, T, togglefloating,"
        "$mainMod, R, exec, launcher"
        "SUPER CTRL, Return, exec, launcher"
        "$mainMod, P, pseudo,"
        "$mainMod, J, layoutmsg, togglesplit"
        "$mainMod, left, movefocus, l"
        "$mainMod, right, movefocus, r"
        "$mainMod, up, movefocus, u"
        "$mainMod, down, movefocus, d"
        "$mainMod SHIFT, left, resizeactive, -50 0"
        "$mainMod SHIFT, right, resizeactive, 50 0"
        "$mainMod SHIFT, up, resizeactive, 0 -50"
        "$mainMod SHIFT, down, resizeactive, 0 50"
        "$mainMod, 1, workspace, 1"
        "$mainMod, 2, workspace, 2"
        "$mainMod, 3, workspace, 3"
        "$mainMod, 4, workspace, 4"
        "$mainMod, 5, workspace, 5"
        "$mainMod, 6, workspace, 6"
        "$mainMod, 7, workspace, 7"
        "$mainMod, 8, workspace, 8"
        "$mainMod, 9, workspace, 9"
        "$mainMod, 0, workspace, 10"
        "$mainMod SHIFT, 1, movetoworkspace, 1"
        "$mainMod SHIFT, 2, movetoworkspace, 2"
        "$mainMod SHIFT, 3, movetoworkspace, 3"
        "$mainMod SHIFT, 4, movetoworkspace, 4"
        "$mainMod SHIFT, 5, movetoworkspace, 5"
        "$mainMod SHIFT, 6, movetoworkspace, 6"
        "$mainMod SHIFT, 7, movetoworkspace, 7"
        "$mainMod SHIFT, 8, movetoworkspace, 8"
        "$mainMod SHIFT, 9, movetoworkspace, 9"
        "$mainMod SHIFT, 0, movetoworkspace, 10"
        "$mainMod SHIFT, P, exec, sh -c 'grim -g \"$(slurp)\" - | swappy -f -'"
        "$mainMod, S, togglespecialworkspace, magic"
        "$mainMod SHIFT, S, movetoworkspace, special:magic"
        "$mainMod, mouse_down, workspace, e+1"
        "$mainMod, mouse_up, workspace, e-1"
      ];

      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];

      bindel = [
        ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        ", XF86MonBrightnessUp, exec, brightnessctl -e4 -n2 set 5%+"
        ", XF86MonBrightnessDown, exec, brightnessctl -e4 -n2 set 5%-"
      ];

      bindl = [
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPause, exec, playerctl play-pause"
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioPrev, exec, playerctl previous"
      ];

      windowrule = [
      ];
    };
  };
}
