{ inputs, ... }:
{
  age.secrets = {
    ariaImmichDatabase.file = "${inputs.secrets}/ariaImmichDatabase.age";
    resticPassword = {
      file = "${inputs.secrets}/resticPassword.age";
      owner = "restic";
    };
  };
}
