{
  config,
  inputs,
  pkgs,
  ...
}:
{
  nix.settings.trusted-users = [ "notthebee" ];

  age.secrets.hashedUserPassword = {
    file = "${inputs.secrets}/hashedUserPassword.age";
  };

  users = {
    users = {
      notthebee = {
        shell = pkgs.zsh;
        uid = 1000;
        isNormalUser = true;
        hashedPasswordFile = config.age.secrets.hashedUserPassword.path;
        extraGroups = [
          "wheel"
          "users"
          "video"
          "podman"
          "input"
        ];
        group = "notthebee";
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKGUGMUo1dRl9xoDlMxQGb8dNSY+6xiEpbZWAu6FAbWw moe@notthebe.ee"
        ];
      };
    };
    groups = {
      notthebee = {
        gid = 1000;
      };
    };
  };
  programs.zsh.enable = true;

}
