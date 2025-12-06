{
  inputs,
  lib,
  config,
  ...
}:
{
  age.secrets.gitIncludes = {
    file = "${inputs.secrets}/gitIncludes.age";
    path = "$HOME/.config/git/includes";
  };

  programs.git = {
    enable = true;

    settings = {
      user = {
        name = "Wolfgang";
        email = "mail@weirdrescue.pw";
      };
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
