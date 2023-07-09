{ config, pkgs, lib, builtins, ... }:
let
  inherit (lib) mkIf types mkDefault mkOption mkMerge strings;
  inherit (builtins) head toString map tail;
in {
  options.email = {
    fromAddress = mkOption {
      description = "The 'from' address";
      type = types.str;
      default = "john@example.com";
    };
    toAddress = mkOption {
      description = "The 'to' address";
      type = types.str;
      default = "john@example.com";
    };
    smtpServer = mkOption {
      description = "The SMTP server address";
      type = types.str;
      default = "smtp.example.com";
    };
    smtpUsername = mkOption {
      description = "The SMTP username";
      type = types.str;
      default = "john@example.com";
    };
    smtpPasswordPath = mkOption {
      description = "Path to the secret containing SMTP password";
      type = types.path;
    };
    };

  config.programs.msmtp = {
    enable = true;
    accounts.default = {
      auth = true;
      host = config.email.smtpServer;
      from = config.email.fromAddress;
      user = config.email.smtpUsername;
      tls = true;
      passwordeval = "cat ${config.email.smtpPasswordPath}";
    };
  };


  }
