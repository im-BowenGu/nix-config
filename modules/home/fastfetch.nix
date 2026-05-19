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
          "text": "LANG=C ${pkgs.tuptime}/bin/tuptime 2>/dev/null | ${pkgs.gawk}/bin/awk '/running/{print $5, $6; exit}'",
          "format": "{}"
        },
        "packages",
        "shell",
        "de",
        "wm",
        "terminal",
        "terminalfont",
        "cpu",
        "gpu",
        "memory",
        "disk",
        "break",
        "colors"
      ]
    }
  '';
}
