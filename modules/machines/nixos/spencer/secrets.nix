{ inputs, ... }:
{
  age.secrets = {
    wireguardPrivateKeySpencer.file = "${inputs.secrets}/wireguardPrivateKeySpencer.age";
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
