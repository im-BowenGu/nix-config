{ pkgs, lib, config, ... }:

let
  dataDir = "/data/ai";
in {
  # ── Ollama (CUDA accelerated) ──
  services.ollama = {
    enable = true;
    package = pkgs.ollama-cuda;
    host = "127.0.0.1";
    port = 11434;
    home = "${dataDir}/ollama";
    models = "${dataDir}/ollama/models";
    openFirewall = false;
  };

  # ── Open WebUI (frontend for Ollama) ──
  services.open-webui = {
    enable = true;
    host = "127.0.0.1";
    port = 8080;
    stateDir = "${dataDir}/open-webui";
    openFirewall = false;
    environment = {
      OLLAMA_API_BASE_URL = "http://127.0.0.1:11434";
    };
  };

  systemd.services.open-webui.serviceConfig = {
    PrivateUsers = lib.mkForce false;
    ReadWritePaths = [ "${dataDir}/open-webui" ];
  };

  # ── llama.cpp server (disabled by default; enable for direct model serving) ──
  services.llama-cpp = {
    enable = false;
    port = 8081;
    modelsDir = "${dataDir}/llama-models";
    openFirewall = false;
  };

  # ── AnythingLLM via Podman ──
  systemd.tmpfiles.rules = [
    "d ${dataDir}/ollama    0755 secret-star users -"
    "d ${dataDir}/open-webui 0755 secret-star users -"
    "d ${dataDir}/anythingllm 0755 secret-star users -"
  ];
  virtualisation.oci-containers = {
    backend = "podman";
    containers.anythingllm = {
      image = "mintplexlabs/anythingllm:latest";
      autoStart = false;
      ports = [ "127.0.0.1:3001:3001/tcp" ];
      environment = {
        STORAGE_DIR = "/app/server/storage";
        OPEN_AI_BASE_URL = "http://host.containers.internal:11434/v1";
      };
      volumes = [
        "${dataDir}/anythingllm:/app/server/storage"
      ];
      extraOptions = [
        "--network=host"
      ];
    };
  };

  # ── AI/ML system packages ──
  environment.systemPackages = with pkgs; [
    ollama-cuda
    open-webui
    llama-cpp
    uv
    python312Packages.pip
    python312Packages.virtualenv
  ];
}
