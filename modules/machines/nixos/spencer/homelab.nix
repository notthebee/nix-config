{ config, ... }:
{
  homelab = {
    baseDomain = "notthebe.ee";
    cloudflare.dnsCredentialsFile = config.age.secrets.cloudflareDnsApiCredentialsNotthebee.path;
    services = {
      enable = true;
      forgejo.enable = true;
      matrix = {
        registrationSecretFile = config.age.secrets.matrixRegistrationSecret.path;
        enable = true;
      };
      plausible = {
        enable = true;
        secretKeybaseFile = config.age.secrets.plausibleSecretKeybaseFile.path;
      };
    };
  };
}
