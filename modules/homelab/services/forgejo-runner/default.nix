{
  lib,
  pkgs,
  config,
  ...
}:
let
  service = "forgejo-runner";
  cfg = config.homelab.services.${service};
in
{
  options.homelab.services.${service} = {
    enable = lib.mkEnableOption {
      description = "Enable ${service}";
    };
    runnerName = lib.mkOption {
      type = lib.types.str;
      default = config.networking.hostName;
      example = "runner-1";
    };
    forgejoUrl = lib.mkOption {
      type = lib.types.str;
      example = "git.foo.bar";
    };
    tokenFile = lib.mkOption {
      type = lib.types.str;
      example = lib.literalExpression ''
        pkgs.writeText "token.txt" '''
          TOKEN=foobar
        '''
      '';
    };
  };
  config = lib.mkIf cfg.enable {
    virtualisation.podman.enable = true;
    services.gitea-actions-runner = {
      package = pkgs.forgejo-runner;
      instances.default = {
        enable = true;
        url = "https://${cfg.forgejoUrl}";
        name = config.networking.hostName;
        tokenFile = cfg.tokenFile;
        labels = [
          "debian-13:docker://debian:13"
          "debian-12:docker://debian:12"
          "ubuntu-24.04:docker://ubuntu:24.04"
          "ubuntu-22.04:docker://ubuntu:22.04"
        ];
      };
    };
  };
}
