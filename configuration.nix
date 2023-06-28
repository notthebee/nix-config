{ my-config, zfs-root, inputs, pkgs, lib, ... }: {
  # load module config to top-level configuration
  inherit my-config zfs-root;

  # Let 'nixos-version --json' know about the Git revision
  # of this flake.
  system.configurationRevision = if (inputs.self ? rev) then
    inputs.self.rev
  else
    throw "refuse to build: git tree is dirty";

  system.stateVersion = "22.11";

  # Enable NetworkManager for wireless networking,
  # You can configure networking with "nmtui" command.
  networking.useDHCP = true;
  networking.networkmanager.enable = false;

  users.users = {
    notthebee = {
      isNormalUser = true;
      initialHashedPassword = "$6$tuU72Dtl7DhP1Hui$9pNeY3AkjcVNv90Nvo9EjTAaxizPaPMp0Cq0n4j89NvB3BWcya2hwNZ1i7OZ1neSLlQGGjXdg3fjn/X7aWIui0";
      openssh.authorizedKeys.keys = [ "sshKey_placeholder" ];
      };
    root = {
      initialHashedPassword = "$6$tuU72Dtl7DhP1Hui$9pNeY3AkjcVNv90Nvo9EjTAaxizPaPMp0Cq0n4j89NvB3BWcya2hwNZ1i7OZ1neSLlQGGjXdg3fjn/X7aWIui0";
      openssh.authorizedKeys.keys = [ "sshKey_placeholder" ];
    };
  };

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
  };

  imports = [
    "${inputs.nixpkgs}/nixos/modules/installer/scan/not-detected.nix"
    # "${inputs.nixpkgs}/nixos/modules/profiles/qemu-guest.nix"
  ];

  services.openssh = {
    enable = lib.mkDefault true;
    settings = { PasswordAuthentication = lib.mkDefault true; };
  };

  boot.zfs.forceImportRoot = lib.mkDefault false;

  nix.settings.experimental-features = lib.mkDefault [ "nix-command" "flakes" ];

  programs.git.enable = true;

  security = {
    doas.enable = lib.mkDefault true;
    sudo.enable = lib.mkDefault false;
  };

  environment.systemPackages = builtins.attrValues {
    inherit (pkgs)
      mg # emacs-like editor
      jq # other programs
    ;
  };
}
