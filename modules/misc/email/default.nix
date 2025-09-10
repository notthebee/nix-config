{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.email;
in
{
  options.email = {
    enable = lib.mkEnableOption "Email sending functionality";
    fromAddress = lib.mkOption {
      description = "The 'from' address";
      type = lib.types.str;
      default = "john@example.com";
    };
    toAddress = lib.mkOption {
      description = "The 'to' address";
      type = lib.types.str;
      default = "john@example.com";
    };
    smtpServer = lib.mkOption {
      description = "The SMTP server address";
      type = lib.types.str;
      default = "smtp.example.com";
    };
    smtpUsername = lib.mkOption {
      description = "The SMTP username";
      type = lib.types.str;
      default = "john@example.com";
    };
    smtpPasswordPath = lib.mkOption {
      description = "Path to the secret containing SMTP password";
      type = lib.types.path;
    };
  };

  config = lib.mkIf cfg.enable {
    programs.msmtp = {
      enable = true;
      accounts.default = {
        auth = true;
        host = config.email.smtpServer;
        from = config.email.fromAddress;
        user = config.email.smtpUsername;
        tls = true;
        passwordeval = "${pkgs.coreutils}/bin/cat ${config.email.smtpPasswordPath}";
      };
    };
  };

}
