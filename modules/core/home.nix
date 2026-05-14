{ pkgs, inputs, ... }:

{
  imports = [
    ./noctalia.nix
  ];

  home.packages = with pkgs; [
    inputs.awww.packages.${pkgs.stdenv.hostPlatform.system}.awww
    hyprland
    jq
    libnotify
    brightnessctl
    playerctl
  ];

  home.file = {
    ".config/hypr/scripts/hyprland-change-layout" = {
      source = pkgs.writeShellScriptBin "hyprland-change-layout" ''
        #!/usr/bin/env bash
        set -euo pipefail

        layouts=(dwindle master monocle)

        get_layout() {
          ${pkgs.hyprland}/bin/hyprctl -j getoption general:layout | ${pkgs.jq}/bin/jq -r '.str'
        }

        next_layout() {
          local current="$1"
          local i
          for i in "''${!layouts[@]}"; do
            if [[ "''${layouts[i]}" == "$current" ]]; then
              echo "''${layouts[((i + 1) % ''${#layouts[@]})]}"
              return
            fi
          done
          echo "''${layouts[0]}"
        }

        set_layout() {
          local target="$1"

          ${pkgs.hyprland}/bin/hyprctl keyword general:layout "$target"
          ${pkgs.hyprland}/bin/hyprctl keyword unbind SUPER,J || true
          ${pkgs.hyprland}/bin/hyprctl keyword unbind SUPER,K || true
          ${pkgs.hyprland}/bin/hyprctl keyword unbind SUPER,O || true
          ${pkgs.hyprland}/bin/hyprctl keyword unbind SUPER_SHIFT,M || true

          case "$target" in
          "dwindle")
            ${pkgs.hyprland}/bin/hyprctl keyword bind SUPER,J,cyclenext
            ${pkgs.hyprland}/bin/hyprctl keyword bind SUPER,K,cyclenext,prev
            ${pkgs.hyprland}/bin/hyprctl keyword bind SUPER,O,layoutmsg,togglesplit
            ${pkgs.libnotify}/bin/notify-send -e -u low "Layout: Dwindle"
            ;;
          "master")
            ${pkgs.hyprland}/bin/hyprctl keyword bind SUPER,J,layoutmsg,cyclenext
            ${pkgs.hyprland}/bin/hyprctl keyword bind SUPER,K,layoutmsg,cycleprev
            ${pkgs.libnotify}/bin/notify-send -e -u low "Layout: Master"
            ;;
          "monocle")
            ${pkgs.hyprland}/bin/hyprctl keyword bind SUPER,J,layoutmsg,cyclenext
            ${pkgs.hyprland}/bin/hyprctl keyword bind SUPER,K,layoutmsg,cycleprev
            ${pkgs.libnotify}/bin/notify-send -e -u low "Layout: Monocle"
            ;;
          *)
            echo "Unknown layout: $target" >&2
            return 1
            ;;
          esac
        }

        current="$(get_layout)"
        arg="''${1:-toggle}"

        case "$arg" in
        init)
          set_layout "$current"
          ;;
        toggle|next)
          set_layout "$(next_layout "$current")"
          ;;
        set)
          set_layout "''${2:-}"
          ;;
        master|dwindle|monocle)
          set_layout "$arg"
          ;;
        *)
          echo "Usage: $(basename "$0") [toggle|next|init|set <layout>|master|dwindle|monocle]" >&2
          exit 1
          ;;
        esac
      '';
      executable = true;
    };
  };

  programs.bash.profileInit = ''
    # Initialize layout from current config
    hyprland-change-layout init 2>/dev/null || true
  '';
}