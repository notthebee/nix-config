{ inputs, lib, ... }:
{
  age.secrets = {
    wireguardPrivateKeySpencer = {
      file = "${inputs.secrets}/wireguardPrivateKeySpencer.age";
      owner = "systemd-network";
    };
    matrixRegistrationSecret = {
      owner = "matrix-synapse";
      group = "matrix-synapse";
      file = "${inputs.secrets}/matrixRegistrationSecret.age";
    };
    plausibleSecretKeybaseFile = {
      owner = "plausible";
      group = "plausible";
      file = "${inputs.secrets}/plausibleSecretKeybaseFile.age";
    };
    forgejoRunnerTokenSpencer = {
      owner = "gitea-runner";
      group = "gitea-runner";
      file = "${inputs.secrets}/forgejoRunnerTokenSpencer.age";
    };
    smtpPassword = {
      owner = "notthebee";
      group = lib.mkForce "forgejo";
      mode = "0440";
    };
    cloudflareDnsApiCredentialsNotthebee.file = "${inputs.secrets}/cloudflareDnsApiCredentialsNotthebee.age";
  };
}
