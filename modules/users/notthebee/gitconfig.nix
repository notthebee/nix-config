{
  inputs,
  lib,
  config,
  ...
}:
{
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
        path = "~/.config/git/includes";
        condition = "gitdir:~/Workspace/Projects/";
      }
    ];
  };
}
