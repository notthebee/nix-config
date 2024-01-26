{ config, pkgs, ... }: 
let
sensor-exporter = pkgs.callPackage (import ./sensor-exporter.nix) { };
in {
  environment.systemPackages = [ 
  sensor-exporter
  ];
}
