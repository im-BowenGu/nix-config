{ pkgs, lib, config, ... }:

let
  pywalfoxBin = lib.getExe pkgs.pywalfox-native;

  nmhManifest = {
    name = "pywalfox";
    description = "Host app for the Pywalfox browser extension";
    path = "${pywalfoxBin}";
    type = "stdio";
    allowed_extensions = [ "pywalfox@frewacom.org" ];
  };

  librewolfAppId = "io.gitlab.librewolf-community";
  librewolfDataDir = ".var/app/${librewolfAppId}";

  # Catppuccin Mocha colors in pywal format
  walColors = {
    special = {
      background = "#1e1e2e";
      foreground = "#cdd6f4";
      cursor = "#cdd6f4";
    };
    colors = {
      color0 = "#1e1e2e";
      color1 = "#f38ba8";
      color2 = "#a6e3a1";
      color3 = "#f9e2af";
      color4 = "#89b4fa";
      color5 = "#cba6f7";
      color6 = "#94e2d5";
      color7 = "#cdd6f4";
      color8 = "#6c7086";
      color9 = "#f38ba8";
      color10 = "#a6e3a1";
      color11 = "#f9e2af";
      color12 = "#89b4fa";
      color13 = "#cba6f7";
      color14 = "#94e2d5";
      color15 = "#b4befe";
    };
    wallpaper = "";
  };
in {
  home.packages = with pkgs; [
    pywalfox-native
  ];

  # Flatpak files must be real files (not symlinks) since the sandbox
  # can't see /nix/store/. These are set up via an activation script.
  home.activation.pywalfox = lib.hm.dag.entryAfter ["writeBoundary"] ''
    run mkdir -p "$HOME/.mozilla/native-messaging-hosts"
    run cat > "$HOME/.mozilla/native-messaging-hosts/pywalfox.json" << 'MANIFEST_EOF'
    ${builtins.toJSON nmhManifest}
    MANIFEST_EOF

    run mkdir -p "$HOME/${librewolfDataDir}"
    run cat > "$HOME/${librewolfDataDir}/pywalfox-wrapper.sh" << 'WRAPPER_EOF'
    #!/bin/sh
    flatpak-spawn --host ${pywalfoxBin} "$@"
    WRAPPER_EOF
    run chmod +x "$HOME/${librewolfDataDir}/pywalfox-wrapper.sh"

    run mkdir -p "$HOME/${librewolfDataDir}/.librewolf/native-messaging-hosts"
    run cat > "$HOME/${librewolfDataDir}/.librewolf/native-messaging-hosts/pywalfox.json" << 'MANIFEST_EOF'
    ${builtins.toJSON (nmhManifest // {
      path = "/home/${config.home.username}/${librewolfDataDir}/pywalfox-wrapper.sh";
    })}
    MANIFEST_EOF

    run mkdir -p "$HOME/${librewolfDataDir}/.mozilla/native-messaging-hosts"
    run cat > "$HOME/${librewolfDataDir}/.mozilla/native-messaging-hosts/pywalfox.json" << 'MANIFEST_EOF'
    ${builtins.toJSON (nmhManifest // {
      path = "/home/${config.home.username}/${librewolfDataDir}/pywalfox-wrapper.sh";
    })}
    MANIFEST_EOF

    run mkdir -p "$HOME/.cache/wal"
    run cat > "$HOME/.cache/wal/colors.json" << 'WAL_EOF'
    ${builtins.toJSON walColors}
    WAL_EOF

    run mkdir -p "$HOME/.local/share/flatpak/overrides"
    run cat > "$HOME/.local/share/flatpak/overrides/${librewolfAppId}" << 'OVERRIDE_EOF'
    [Session Bus Policy]
    org.freedesktop.Flatpak=talk
    org.freedesktop.portal.Flatpak=talk

    [System Bus Policy]
    org.freedesktop.Flatpak=talk
    OVERRIDE_EOF
  '';
}
