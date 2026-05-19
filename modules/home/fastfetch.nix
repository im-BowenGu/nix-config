{ pkgs, ... }: {
  xdg.configFile."fastfetch/config.jsonc".text = ''
    {
      "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
      "display": {
        "separator": " -> "
      },
      "modules": [
        "title",
        "separator",
        "os",
        "host",
        "kernel",
        {
          "type": "command",
          "key": "Total Uptime",
          "text": "${pkgs.tuptime}/bin/tuptime 2>/dev/null | ${pkgs.gawk}/bin/awk '/System uptime/{for(i=5;i<=NF;i++) printf \"%s \", $i; print \"\"}'",
          "format": "{}"
        },
        "packages",
        "shell",
        "display",
        "de",
        "wm",
        "wmtheme",
        "theme",
        "icons",
        "font",
        "cursor",
        "terminal",
        "terminalfont",
        "cpu",
        "gpu",
        "memory",
        "swap",
        "disk",
        "localip",
        "battery",
        "poweradapter",
        "locale",
        "break",
        "colors"
      ]
    }
  '';
}
