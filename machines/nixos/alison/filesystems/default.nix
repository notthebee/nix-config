{
  lib,
  pkgs,
  ...
}:
{
  programs.fuse.userAllowOther = true;

  environment.systemPackages = with pkgs; [
    gptfdisk
    parted
  ];
}
