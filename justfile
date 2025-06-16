# vim: set ft=make :

update:
  nix flake update

build-iso $host:
	just copy {{ host }}; ssh {{ host }} "nix-shell -p nixos-generators.out --run 'nixos-generate -c /etc/nixos/machines/installer/default.nix -f install-iso -I nixpkgs=channel:nixos-25.05'"

check:
  nix flake check

dry-run $host:
	nixos-rebuild dry-activate --flake .#{{host}} --target-host {{host}} --build-host {{host}} --fast --use-remote-sudo

deploy $host:
	just copy {{ host }}; nixos-rebuild switch --flake .#{{host}} --target-host {{host}} --build-host {{host}} --fast --use-remote-sudo

copy $host:
	rsync -ax --delete --rsync-path="sudo rsync" ./ {{host}}:/etc/nixos/
