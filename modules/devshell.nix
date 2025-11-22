{ inputs, ... }:
{
  systems = [
    "x86_64-linux"
  ];
  imports = [ inputs.treefmt-nix.flakeModule ];
  perSystem =
    { pkgs, system, ... }:
    let
      pkgs-unstable = import inputs.nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
    in
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
          pkgs.nh
          pkgs.nixos-rebuild-ng
          pkgs-unstable.claude-code
        ];
      };
    };
}
