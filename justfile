# vim: set ft=make :
set quiet

update:
  nix flake update

build-iso $host:
	just copy {{ host }}; ssh {{ host }} "nix-shell -p nixos-generators.out --run 'nixos-generate -c /etc/nixos/machines/installer/default.nix -f install-iso -I nixpkgs=channel:nixos-25.05'"

check:
  nix flake check

dry-run $host:
	nixos-rebuild-ng dry-activate --flake .#{{host}} --target-host {{host}} --build-host {{host}} --fast --use-remote-sudo

deploy $host: (copy host)
	nixos-rebuild-ng switch --flake .#{{host}} --target-host {{host}} --build-host {{host}} --fast --use-remote-sudo

check-clean:
	if [ -n "$(git status --porcelain)" ]; then echo -e "\e[31merror\e[0m: git tree is dirty. Refusing to copy configuration." >&2; exit 1; fi

copy $host: check-clean
	rsync -ax --delete --rsync-path="sudo rsync" ./ {{host}}:/etc/nixos/
