# My NixOS Configuration

Personal NixOS flake configuration for my ThinkBook 16p laptop with Hyprland.

## Features

- **Hyprland** - Wayland compositor
- **Noctalia Shell** - Status bar
- **NVIDIA prime + Intel** - Hybrid GPU setup
- **CachyOS Kernel** - Optimized kernel
- **Stylix** - Automatic theming from wallpaper

## Structure

```
.
├── flake.nix
├── hosts/                 # Host-specific configurations
│   └── thinkbook-16p/    # My laptop config
├── modules/              # Reusable modules
│   └── core/             # Core system modules
├── profiles/              # GPU profiles
│   └── nvidia-intel-hybrid/
└── wallpapers/           # Wallpaper files
```

## Build

```bash
sudo nixos-rebuild switch --flake .#thinkbook-16p
```
Note: thinkbook-16p is my config, you can build your own in hosts/
## License

AGPL-3.0
