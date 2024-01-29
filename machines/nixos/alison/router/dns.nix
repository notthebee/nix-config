{ lib, config, pkgs, vars, ... }:
{
  services.https-dns-proxy = {
    enable = true;
    port = 10053;
    extraArgs = [
    "-vvv"
    ];
  };
}
