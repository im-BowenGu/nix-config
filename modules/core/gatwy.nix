{ pkgs, ... }:
{
  virtualisation.oci-containers = {
    backend = "podman";
    containers.gatwy = {
      image = "ghcr.io/kotoxie/gatwy:latest";
      autoStart = true;
      ports = [ "7443:7443" ];
      volumes = [ "/data/gatwy:/app/data" ];
      environment = { GATWY_ENCRYPTION_KEY = "your-64-char-hex-key"; };
    };
  };
}
