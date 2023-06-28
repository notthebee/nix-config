{ config, lib, pkgs, ... }: {
  imports = [ ./boot ./fileSystems ./networking ./my-config ];
}
