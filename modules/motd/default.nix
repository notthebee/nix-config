{ config, pkgs, ... }: 
let
motd = pkgs.writeShellScriptBin "motd" (builtins.readFile ./motd.sh);
in {
  environment.systemPackages = [ 
  motd
  ];
}
