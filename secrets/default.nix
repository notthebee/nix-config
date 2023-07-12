{ lib, inputs, ... }: 
{
  age.identityPaths = ["/etc/ssh/ssh_host_ed25519_key"];

  age.secrets.hashedUserPassword = lib.mkDefault {
    file = ./hashedUserPassword.age;
  };
  age.secrets.sambaPassword = lib.mkDefault {
    file = ./sambaPassword.age;
    };
  age.secrets.telegramApiKey = lib.mkDefault {
    file = ./telegramApiKey.age;
    owner = "notthebee";
    group = "notthebee";
    mode = "640";
    };
  age.secrets.telegramChannelId = lib.mkDefault {
    file = ./telegramChannelId.age;
    owner = "notthebee";
    group = "notthebee";
    mode = "640";
    };
  age.secrets.smtpPassword = lib.mkDefault {
    file = ./smtpPassword.age;
    owner = "notthebee";
    group = "notthebee";
    mode = "770";
  };
  age.secrets.wireguardCredentials = lib.mkDefault {
      file = ./wireguardCredentials.age;
    };
  age.secrets.cloudflareDnsApiCredentials = lib.mkDefault {
      file = ./cloudflareDnsApiCredentials.age;
    };
  age.secrets.invoiceNinja = lib.mkDefault {
      file = ./invoiceNinja.age;
    };
  age.secrets.radarrApiKey = lib.mkDefault {
      file = ./radarrApiKey.age;
    };
  age.secrets.sonarrApiKey = lib.mkDefault {
      file = ./sonarrApiKey.age;
    };
  age.secrets.tailscaleAuthKey = lib.mkDefault {
      file = ./sonarrApiKey.age;
    };
  age.secrets.paperless = lib.mkDefault {
      file = ./paperless.age;
    };
}
