{ pkgs, ... }:

{
  programs.git = {
    enable = true;
    userName  = "Wolfgang";
    userEmail = "mail@weirdrescue.pw";
  };
}
