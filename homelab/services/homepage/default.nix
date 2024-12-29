{
  config,
  lib,
  ...
}:
let
  service = "homepage-dashboard";
  cfg = config.homelab.services.homepage;
  homelab = config.homelab;
in
{
  options.homelab.services.homepage = {
    enable = lib.mkEnableOption {
      description = "Enable ${service}";
    };
  };
  config = lib.mkIf cfg.enable {
    services.${service} = {
      enable = true;
      settings = {
        headerStyle = "clean";
        statusStyle = "dot";
        hideVersion = "true";
        customCSS = ''
          * {
            font-family: SF Pro Display, Helvetica, Arial, sans-serif !important;
          }
          .font-medium {
            font-weight: 700 !important;
          }
          .font-light {
            font-weight: 500 !important;
          }
          .font-thin {
            font-weight: 400 !important;
          }
          #information-widgets {
            padding-left: 1.5rem;
            padding-right: 1.5rem;
          }
          div#footer {
            display: none;
          }
          .services-group.basis-full.flex-1.px-1.-my-1 {
            padding-bottom: 3rem;
          };
        '';
        services = [
          {
            Glances = [
              {
                Info = {
                  widget = {
                    type = "glances";
                    url = "http://localhost:61208";
                    metric = "info";
                    chart = false;
                  };
                };
              }
              {
                "CPU Temp" = {
                  widget = {
                    type = "glances";
                    url = "http://localhost:61208";
                    metric = "sensor:Package id 0";
                    chart = false;
                  };
                };
              }
              {
                Processes = {
                  widget = {
                    type = "glances";
                    url = "http://localhost:61208";
                    metric = "process";
                    chart = false;
                  };
                };
              }
              {
                Network = {
                  widget = {
                    type = "glances";
                    url = "http://localhost:61208";
                    metric = "network:enp1s0";
                    chart = false;
                  };
                };
              }
            ];
          }
        ];
        layout = [
          {
            Glances = {
              header = false;
              style = "row";
              columns = 4;
            };
          }
          { Arr = { }; }
          { Downloads = { }; }
          { Media = { }; }
          { Services = { }; }
        ];
      };
    };
    services.caddy.virtualHosts."${homelab.baseDomain}" = {
      useACMEHost = homelab.baseDomain;
      extraConfig = ''
        reverse_proxy http://127.0.0.1:${toString config.services.${service}.listenPort}
      '';
    };
  };

}
