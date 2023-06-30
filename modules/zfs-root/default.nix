{ config, lib, pkgs, ... }: {
  imports = [ 
  ./boot.nix 
  ./fileSystems.nix 
  ./networking.nix 
  ];
}
