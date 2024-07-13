{ config, pkgs, ... }: 
let
deploy-nix = pkgs.writeShellScriptBin "deploy-nix" ''
#!/usr/bin/env zsh

nix flake update
ssh -t $1 'sudo chown -R $USER /etc/nixos'
rsync -q -avx --delete ./ $1:/etc/nixos/
ssh -t $1 'cd /etc/nixos && sudo nixos-rebuild switch --impure --upgrade --flake .\?submodules=1#$1'
'';

in {
  environment.systemPackages = [ 
    deploy-nix 
  ];
}
