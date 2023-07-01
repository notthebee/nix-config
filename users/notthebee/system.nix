{ config, pkgs, ... }: {

  nix.settings.trusted-users = [ "notthebee" ];

  users.users = {
    notthebee = {
      shell = pkgs.fish;
      isNormalUser = true;
      initialHashedPassword = "$6$tuU72Dtl7DhP1Hui$9pNeY3AkjcVNv90Nvo9EjTAaxizPaPMp0Cq0n4j89NvB3BWcya2hwNZ1i7OZ1neSLlQGGjXdg3fjn/X7aWIui0";
      extraGroups = [ "wheel" "users" "video" "docker" ];
      openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKGUGMUo1dRl9xoDlMxQGb8dNSY+6xiEpbZWAu6FAbWw moe@notthebe.ee" ];
      };
      };

      programs.fish.enable = true;
}
