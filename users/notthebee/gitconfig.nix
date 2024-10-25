{ inputs, lib, config, pkgs, ... }:
{
  age.secrets.gitIncludes = {
    file = "${inputs.secrets}/gitIncludes.age";
    path = "$HOME/.config/git/includes";
  };

  programs.git = {
    enable = true;
    userName = "Wolfgang";
    userEmail = "mail@weirdrescue.pw";

    extraConfig = {
      core = {
        sshCommand = "ssh -o 'IdentitiesOnly=yes' -i ~/.ssh/notthebee";
      };
    };
    includes = [
      {
        path = "~" + (lib.removePrefix "$HOME" config.age.secrets.gitIncludes.path);
        condition = "gitdir:~/Workspace/Projects/";
      }
    ];
  };
}
