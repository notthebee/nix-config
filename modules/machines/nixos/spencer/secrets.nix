{ inputs, ... }:
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
  };
}
