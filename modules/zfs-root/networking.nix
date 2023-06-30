{ config, lib, ... }:
let
  cfg = config.zfs-root.networking;
  inherit (lib) types mkDefault mkOption;
in {
  options.zfs-root.networking = {
    hostName = mkOption {
      description = "The name of the machine.  Used by nix flake.";
      type = types.str;
      default = "exampleHost";
    };
    timeZone = mkOption {
      type = types.str;
      default = "Etc/UTC";
    };
    hostId = mkOption {
      description = "Set host id";
      type = types.str;
    };
  };
  config = {
    networking.hostId = cfg.hostId;
    time.timeZone = cfg.timeZone;
    networking = {
      firewall.enable = mkDefault true;
      hostName = cfg.hostName;
    };
  };
}
