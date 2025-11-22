{
  pkgs,
  ...
}:
{
  nix.settings.trusted-users = [ "bricklayer" ];

  users = {
    users = {
      bricklayer = {
        shell = pkgs.zsh;
        uid = 1000;
        isNormalUser = true;
        extraGroups = [
          "wheel"
          "users"
          "video"
          "podman"
          "input"
        ];
        group = "bricklayer";
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKGUGMUo1dRl9xoDlMxQGb8dNSY+6xiEpbZWAu6FAbWw moe@notthebe.ee"
        ];
      };
    };
    groups = {
      bricklayer = {
        gid = 1000;
      };
    };
  };
  programs.zsh.enable = true;

}
