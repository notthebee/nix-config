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
}
