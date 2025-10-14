{
  inputs,
  config,
  pkgs,
  ...
}:
{
  services.tailscale = {
    package = inputs.nixpkgs-unstable.legacyPackages.${pkgs.system}.tailscale;
    enable = true;
    authKeyFile = config.age.secrets.tailscaleAuthKey.path;
    extraUpFlags = [
      "--reset"
    ];
  };
}
