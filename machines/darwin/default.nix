{ ... }:
{
  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnfreePredicate = (_: true);
    };
  };

  services.karabiner-elements.enable = true;
  nix = {
    settings = {
      max-jobs = "auto";
      trusted-users = [
        "root"
        "notthebee"
        "@admin"
      ];
    };
  };
}
