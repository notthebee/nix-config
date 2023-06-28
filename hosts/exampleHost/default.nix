# #
##
##  per-host configuration for exampleHost
##
##

{ system, pkgs, ... }: {
  inherit pkgs system;
  zfs-root = {
    boot = {
      devNodes = "/dev/disk/by-id/";
      bootDevices = [ "bootDevices_placeholder" ];
      immutable = false;
      availableKernelModules = [ "kernelModules_placeholder" ];
      removableEfi = true;
      kernelParams = [ ];
      sshUnlock = {
        # read sshUnlock.txt file.
        enable = false;
        authorizedKeys = [ ];
      };
    };
    networking = {
      # read changeHostName.txt file.
      hostName = "exampleHost";
      timeZone = "Europe/Berlin";
      hostId = "abcd1234";
    };
  };

  # To add more options to per-host configuration, you can create a
  # custom configuration module, then add it here.
  my-config = {
    # Enable custom gnome desktop on exampleHost
    template.desktop.gnome.enable = false;
  };
}
