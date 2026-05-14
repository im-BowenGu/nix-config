{ pkgs, ... }:

let
  hmcl-fhs = pkgs.buildFHSUserEnv {
    name = "hmcl";
    targetPkgs = pkgs: with pkgs; [
      udev
      alsa-lib
      libGL
      libpulseaudio
      libxkbcommon
      vulkan-loader
      xorg.libX11
      xorg.libXext
      xorg.libXcursor
      xorg.libXrandr
      xorg.libXi
      nss
      nspr
      atk
      at-spi2-atk
      libdrm
      mesa
      expat
      pango
      cairo
      glib
      dbus
      libXcomposite
      libXdamage
      libXfixes
      libXrender
      libxscrnsaver
      libXtst
      libxcb
    ];
    runScript = "${pkgs.hmcl}/bin/hmcl";
  };
in
{
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    hmcl-fhs
    vim
    wget
    gparted
    cryptsetup
    neovim
    fastfetch
    doas-sudo-shim
    kitty
    arch-install-scripts
    eza
    ripgrep
    deno
    podman
    git
    flameshot
    grim
    unzip
    psmisc
    gcc
    gnumake
    opencode
    libinput
    kexec-tools
    gh
    virt-manager
    qemu
    libvirt
    spice-gtk
    spice-vdagent
    swtpm
    guestfs-tools
    clash-meta
    waydroid
    waydroid-helper
    legcord
    graalvmPackages.graalvm-ce
    obs-studio
    pipewire
    btop
    uv
    openvino
    intel-compute-runtime
    pocl
    adaptivecpp
    python3
  ];

  programs.clash-verge = {
    enable = true;
    serviceMode = true;
    tunMode = true;
  };

  networking.firewall.checkReversePath = "loose";
  networking.enableIPv6 = false;

  programs.nix-ld.enable = true;

  virtualisation.libvirtd.enable = true;
  virtualisation.libvirtd.qemu.package = pkgs.qemu;
  virtualisation.spiceUSBRedirection.enable = true;
  services.spice-vdagentd.enable = true;
}