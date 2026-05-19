{ pkgs, ... }:
{
  systemd.tmpfiles.rules = [
    "d /data/gatwy 0755 root root -"
  ];

  virtualisation.oci-containers = {
    backend = "podman";
    containers.gatwy = {
      image = "ghcr.io/kotoxie/gatwy:latest";
      autoStart = true;
      ports = [ "7443:7443" ];
      volumes = [ "/data/gatwy:/app/data" ];
      environment = { GATWY_ENCRYPTION_KEY = "cd8419d0ff76d18b4a6ef2566ec55f424fd320c70e4eb665c1152db476bb77b9"; };
    };
  };
}
