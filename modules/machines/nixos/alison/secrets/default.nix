{ lib, inputs, ... }:
{
  age.secrets.wireguardPrivateKeyAlison = lib.mkDefault {
    owner = "systemd-network";
    file = "${inputs.secrets}/wireguardPrivateKeyAlison.age";
  };
}
