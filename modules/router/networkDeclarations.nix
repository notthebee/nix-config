{ config, lib, pkgs, utils, ... }: 
let
  inherit (lib) mkIf types mkDefault mkOption mkMerge mapAttrsToList literalExpression;
  cfg = config.networks;
in
{
  options.networks = mkOption {
      default = { };
      example = literalExpression ''
        {
          lan = {
            cidr = 192.168.2.1;
            interface = "enp3s0";
            reservations = [];
      };
          iot = {
            cidr = 192.168.3.1;
            interface = "lan";
            reservations = [];
          };
        }
      '';
      type = types.attrsOf (types.submodule {
        options = {
          cidr = mkOption {
            example = "192.168.2.1";
            type = types.str;
          };
          interface = mkOption {
            example = "enp4s0";
            type = types.str;
          };
          trusted = mkOption {
            type = types.bool;
            default = false;
            description = ''
            Whether the network should be trusted. Trusted networks can access all ports and hosts on the local network regardless of the firewall rules
            '';
          };
          dhcp = mkOption {
            type = types.bool;
            default = true;
            description = ''
            Whether to run a DHCP server on the network
            '';
          };
          reservations = mkOption {
            type = types.listOf types.attrs;
            default = [];
            example = literalExpression ''
              [
                { hostname = "optina"; hw-address = "d4:3d:7e:4d:c4:7f"; ip-address = "10.40.33.20"; }
                { hostname = "valaam"; hw-address = "00:c0:08:9d:ba:42"; ip-address = "10.40.33.21"; }
                { hostname = "atari"; hw-address = "94:08:53:84:9b:9d"; ip-address = "10.40.33.22"; }
                { hostname = "kodiak"; hw-address = "ec:f4:bb:e7:4b:dc"; ip-address = "10.40.33.23"; }
                { hostname = "valaam-wifi"; hw-address = "3c:58:c2:f9:87:5b"; ip-address = "10.40.33.31"; }
                { hostname = "printer"; hw-address = "a4:5d:36:d6:22:d9"; ip-address = "10.40.33.50"; }
              ]
            '';
          };

        };
      });
    };

}
