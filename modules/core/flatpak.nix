{ ... }:

{
  services.flatpak.enable = true;

  services.flatpak.packages = [
    { appId = "com.usebottles.bottles"; origin = "flathub"; }
    { appId = "io.gitlab.librewolf-community"; origin = "flathub"; }
    { appId = "org.kde.dolphin"; origin = "flathub"; }
    { appId = "com.github.wwmm.easyeffects"; origin = "flathub"; }
    { appId = "dev.zed.Zed"; origin = "flathub"; }
    { appId = "com.tencent.WeChat"; origin = "flathub"; }
  ];
}