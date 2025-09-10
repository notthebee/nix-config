{ inputs, ... }:
{
  systems = [
    "aarch64-darwin"
  ];
  imports = [ inputs.treefmt-nix.flakeModule ];
  perSystem =
    { pkgs, ... }:
    {
      treefmt = {
        projectRootFile = "flake.nix";
        settings.global.excludes = [
          "*.lock"
          ".gitignore"
          "secrets/*"
        ];
        programs.nixfmt.enable = true;
        programs.nixfmt.package = pkgs.nixfmt-rfc-style;
        programs.deadnix.enable = true;
        programs.shellcheck.enable = true;
      };
      packages.default = pkgs.mkShell {
        packages = [
          pkgs.just
          pkgs.nixos-rebuild-ng
        ];
      };
    };
}
