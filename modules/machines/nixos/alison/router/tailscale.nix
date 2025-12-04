{
  config,
  ...
}:
{
  services.tailscale = {
    enable = true;
    authKeyFile = config.age.secrets.tailscaleAuthKey.path;
    extraUpFlags = [
      "--reset"
    ];
  };
}
