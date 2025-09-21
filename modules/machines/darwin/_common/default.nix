{ ... }:
{
  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnfreePredicate = (_: true);
    };
    overlays = [
      (_self: super: {
        nodejs = super.nodejs_22;
        karabiner-elements = super.karabiner-elements.overrideAttrs (old: {
          version = "14.13.0";

          src = super.fetchurl {
            inherit (old.src) url;
            hash = "sha256-gmJwoht/Tfm5qMecmq1N6PSAIfWOqsvuHU8VDJY8bLw=";
          };
        });
      })
    ];
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
