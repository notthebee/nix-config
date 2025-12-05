{
  config,
  lib,
  pkgs,
  ...
}:
let
  service = "invoiceplane";
  cfg = config.homelab.services.${service};
  hl = config.homelab;
in
{
  options.homelab.services.${service} = {
    enable = lib.mkEnableOption {
      description = "Enable ${service}";
    };
    configDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/${service}";
    };
    dbPasswordFile = lib.mkOption {
      type = lib.types.path;
    };
    url = lib.mkOption {
      type = lib.types.str;
      default = "invoice.${hl.baseDomain}";
    };
    monitoredServices = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "phpfpm-invoiceplane-${cfg.url}"
      ];
    };
    homepage.name = lib.mkOption {
      type = lib.types.str;
      default = "InvoicePlane";
    };
    homepage.description = lib.mkOption {
      type = lib.types.str;
      default = "Invoicing application";
    };
    homepage.icon = lib.mkOption {
      type = lib.types.str;
      default = "invoiceplane.svg";
    };
    homepage.category = lib.mkOption {
      type = lib.types.str;
      default = "Services";
    };
  };
  config = lib.mkIf cfg.enable {
    services.invoiceplane-beta = {
      sites.${cfg.url} = {
        invoiceTemplates =
          let
            notthebee = pkgs.callPackage ./template.nix { };
          in
          [ notthebee ];
        settings = {
          DISABLE_SETUP = true;
          SETUP_COMPLETED = true;
          IP_URL = "https://${cfg.url}";
          DISABLE_READ_ONLY = true;
          ENABLE_INVOICE_DELETION = true;
        };
      };
    };
    services.caddy.virtualHosts."${cfg.url}" =
      let
        url = "http://${cfg.url}";
      in
      {
        useACMEHost = hl.baseDomain;
        extraConfig = config.services.caddy.virtualHosts.${url}.extraConfig;
      };
  };
}
