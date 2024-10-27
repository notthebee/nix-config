{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.services.arr;
  directories = [ "${cfg.mounts.config}/recyclarr" ];
in
{
  options.services.arr.recyclarr = {
    enable = lib.mkOption {
      default = true;
      type = lib.types.bool;
      description = "Enable Recyclarr";
    };
    configPath = lib.mkOption {
      default = true;
      type = lib.types.package;
      description = "Path to the Recyclarr config files";
    };
  };

  config = lib.mkIf cfg.recyclarr.enable {
    systemd.tmpfiles.rules = map (x: "d ${x} 0775 ${cfg.user} ${cfg.group} - -") directories;
    system.activationScripts.recyclarr_configure = ''
      sed=${pkgs.gnused}/bin/sed
      configFile=${cfg.mounts.config}/recyclarr/recyclarr.yml
      sonarr="${cfg.recyclarr.configPath}/sonarr/templates/web-2160p-v4.yml"
      sonarrApiKey=$(cat "${cfg.sonarr.apiKeyFile}")
      radarr="${cfg.recyclarr.configPath}/radarr/templates/remux-web-2160p.yml"
      radarrApiKey=$(cat "${cfg.radarr.apiKeyFile}")

      cat $sonarr > $configFile
      $sed -i"" "s/Put your API key here/$sonarrApiKey/g" $configFile
      $sed -i"" "s/Put your Sonarr URL here/https:\/\/sonarr.${cfg.baseDomainName}/g" $configFile

      printf "\n" >> ${cfg.mounts.config}/recyclarr/recyclarr.yml
      cat $radarr >> ${cfg.mounts.config}/recyclarr/recyclarr.yml
      $sed -i"" "s/Put your API key here/$radarrApiKey/g" $configFile
      $sed -i"" "s/Put your Radarr URL here/https:\/\/radarr.${cfg.baseDomainName}/g" $configFile

    '';

    virtualisation.oci-containers = {
      containers = {
        recyclarr = {
          image = "ghcr.io/recyclarr/recyclarr";
          user = "${cfg.user}:${cfg.group}";
          autoStart = true;
          volumes = [ "${cfg.mounts.config}/recyclarr:/config" ];
          environment = {
            CRON_SCHEDULE = "@daily";
          };
          extraOptions = [ "--pull=newer" ];
        };
      };
    };
  };
}
