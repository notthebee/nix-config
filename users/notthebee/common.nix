{ inputs, lib, config, pkgs, ... }: {
  users.users = {
    notthebee = {
      shell = "/run/current-system/sw/bin/fish";
      isNormalUser = true;
      initialHashedPassword = "$6$tuU72Dtl7DhP1Hui$9pNeY3AkjcVNv90Nvo9EjTAaxizPaPMp0Cq0n4j89NvB3BWcya2hwNZ1i7OZ1neSLlQGGjXdg3fjn/X7aWIui0";
      extraGroups = [ "wheel" "users" ];
      openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKGUGMUo1dRl9xoDlMxQGb8dNSY+6xiEpbZWAu6FAbWw moe@notthebe.ee" ];
      };


  };
  home-manager.users.notthebee = {

  imports = [
  ./configs/fish/default.nix
  ./configs/git/default.nix
  ];

  nixpkgs = {
  overlays = [
    ];
    config = {
      allowUnfree = true;
      allowUnfreePredicate = (_: true);
    };
  };

home = {
  username = "notthebee";
  homeDirectory = "/home/notthebee";
};

programs.home-manager.enable = true;

systemd.user.startServices = "sd-switch";
home.stateVersion = "23.05";

};
}
