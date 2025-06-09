{ inputs, ... }:
{
  age.secrets = {
    bwSession.file = "${inputs.secrets}/bwSession.age";
  };
}
