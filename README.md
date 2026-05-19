# My NixOS Configuration

Personal NixOS flake configuration for my ThinkBook 16p laptop with Hyprland.

## Features

- **Hyprland** - Wayland compositor
- **Noctalia Shell** - Status bar
- **NVIDIA + Intel PRIME** - Hybrid GPU setup
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

## License

AGPL-3.0