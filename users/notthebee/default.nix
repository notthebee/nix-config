{ config, pkgs, ... }: {

  nix.settings.trusted-users = [ "notthebee" ];

  age.identityPaths = ["/home/notthebee/.ssh/notthebee"];

  age.secrets.hashedUserPassword = {
    file = ../../secrets/hashedUserPassword.age;
  };

  email = {
    fromAddress = "moe@notthebe.ee";
    toAddress = "server_announcements@mailbox.org";
    smtpServer = "in-v3.mailjet.com";
    smtpUsername = "223523d7459305169d27b42cb595385e";
    smtpPasswordPath = config.age.secrets.smtpPassword.path;
  };

  programs.msmtp = {
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

  users = {
    users = {
      notthebee = {
        shell = pkgs.fish;
        uid = 1000;
        isNormalUser = true;
        passwordFile = config.age.secrets.hashedUserPassword.path;
        extraGroups = [ "wheel" "users" "video" "docker" ];
        group = "notthebee";
        openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKGUGMUo1dRl9xoDlMxQGb8dNSY+6xiEpbZWAu6FAbWw moe@notthebe.ee" ];
      };
    };
    groups = {
      notthebee = {
        gid= 1000;
      };
    };
  };

  programs.fish.enable = true;

}
