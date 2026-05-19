{ pkgs, inputs, ... }:

let
  hmcl-desktop = pkgs.makeDesktopItem {
    name = "hmcl";
    desktopName = "HMCL";
    exec = "hmcl";
    icon = "minecraft";
    categories = [ "Game" ];
  };
in {
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
    brightnessctl
    playerctl
    kitty
    obsidian
    wlogout
    freerdp-shadow-cli
    (python3.withPackages (ps: with ps; [ pip pygobject3 screeninfo ]))
    inputs.awww.packages.${pkgs.stdenv.hostPlatform.system}.awww
    hmcl-desktop
    (pkgs.writeShellScriptBin "efftoggle" ''
      set -euo pipefail

      NVIDIA_PCI="0000:02:00.0"
      NVIDIA_SYSFS="/sys/bus/pci/devices/$NVIDIA_PCI"
      KEEP_CORES="0 8 12 16"

      CMD=''${1:-status}

      park() {
        for cpu in /sys/devices/system/cpu/cpu[0-9]*; do
          local idx=''${cpu##*/cpu}
          local keep=0
          for k in $KEEP_CORES; do
            [ "$idx" = "$k" ] && keep=1
          done
          [ "$keep" -eq 1 ] && continue
          echo 0 > "$cpu/online" 2>/dev/null || true
        done
      }

      unpark() {
        for cpu in /sys/devices/system/cpu/cpu[0-9]*; do
          local idx=''${cpu##*/cpu}
          [ "$idx" -eq 0 ] && continue
          echo 1 > "$cpu/online" 2>/dev/null || true
        done
      }

      set_governor() {
        local gov=$1
        for cpu in /sys/devices/system/cpu/cpu[0-9]*/cpufreq/scaling_governor; do
          echo "$gov" > "$cpu" 2>/dev/null || true
        done
      }

      throttle() {
        set_governor powersave
        local max=$(cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_min_freq 2>/dev/null || echo 0)
        [ "$max" -gt 0 ] || max=800000
        for cpu in /sys/devices/system/cpu/cpu[0-9]*/cpufreq/scaling_max_freq; do
          echo "$max" > "$cpu" 2>/dev/null || true
        done
      }

      restore() {
        set_governor performance
        for cpu in /sys/devices/system/cpu/cpu[0-9]*/cpufreq/scaling_max_freq; do
          local max=$(cat "''${cpu%/*}/cpuinfo_max_freq" 2>/dev/null || true)
          [ -n "$max" ] && echo "$max" > "$cpu" 2>/dev/null || true
        done
      }

      dgpu_off() {
        if [ ! -f "$NVIDIA_SYSFS/power/control" ]; then
          echo "NVIDIA GPU not found at $NVIDIA_PCI"
          exit 1
        fi
        local pids=$(nvidia-smi --query-compute-apps=pid --format=csv,noheader 2>/dev/null | tr -d ' ' | grep -v '^$' || true)
        if [ -n "$pids" ]; then
          echo "Processes still using dGPU, cannot power off"
          nvidia-smi
          exit 1
        fi
        echo "auto" > "$NVIDIA_SYSFS/power/control" 2>/dev/null || true
        local base=''${NVIDIA_SYSFS%???}
        echo "auto" > "$base"1/power/control 2>/dev/null || true
        rmmod nvidia_drm nvidia_modeset nvidia_uvm nvidia 2>/dev/null || true
        if ! lsmod | grep -q "^nvidia "; then
          echo "dGPU powered off"
        else
          echo "Failed to unload nvidia modules"
          exit 1
        fi
      }

      dgpu_on() {
        echo "on" > "$NVIDIA_SYSFS/power/control" 2>/dev/null || true
        local base=''${NVIDIA_SYSFS%???}
        echo "on" > "$base"1/power/control 2>/dev/null || true
        modprobe nvidia nvidia_modeset nvidia_uvm nvidia_drm 2>/dev/null || true
        if lsmod | grep -q "^nvidia "; then
          echo "dGPU powered on"
        else
          echo "Failed to load nvidia modules"
          exit 1
        fi
      }

      case "$CMD" in
        park) park ;;
        unpark) unpark ;;
        throttle) throttle ;;
        restore) restore ;;
        dgpu-off) dgpu_off ;;
        dgpu-on) dgpu_on ;;
        battery)
          park
          throttle
          if lsmod | grep -q "^nvidia "; then
            dgpu_off 2>/dev/null || true
          fi
          echo "Battery mode active"
          ;;
        ac)
          unpark
          restore
          if [ -f "$NVIDIA_SYSFS/power/control" ]; then
            dgpu_on 2>/dev/null || true
          fi
          echo "AC mode active"
          ;;
        status)
          echo "=== CPU ==="
          echo "Kept cores: $KEEP_CORES"
          echo "Online CPUs: $(ls -d /sys/devices/system/cpu/cpu[0-9]*/online 2>/dev/null | xargs -I{} sh -c 'echo "$(basename $(dirname {})): $(cat {})"')"
          echo "Scaling max freq: $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq 2>/dev/null || echo N/A)"
          echo
          echo "=== dGPU ==="
          if lsmod | grep -q "^nvidia "; then
            nvidia-smi --query-gpu=index,name,temperature.gpu,power.draw,utilization.gpu --format=csv,noheader 2>/dev/null || echo "NVIDIA loaded"
          else
            echo "NVIDIA dGPU: OFF"
          fi
          ;;
        *)
          echo "Usage: efftoggle {park|unpark|throttle|restore|dgpu-off|dgpu-on|battery|ac|status}"
          ;;
      esac
    '')
    (pkgs.writeShellScriptBin "launcher" ''
      QS_PID=$(pgrep -f quickshell 2>/dev/null | head -1)
      if [ -n "$QS_PID" ]; then
        exec qs ipc --pid "$QS_PID" call launcher toggle
      fi
    '')
  ];
}
