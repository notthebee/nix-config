{ lib, config, ... }:
let
  cfg = config.homelab.networks;
in
{
  options.homelab.networks = {
    external = lib.mkOption {
      default = { };
      example = lib.literalExpression ''
        hostname = {
          address = "192.168.2.2";
          gateway = "192.168.2.1";
          interface = "enp1s0";
        };
      '';
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            address = lib.mkOption {
              example = "192.168.2.2";
              type = lib.types.str;
            };
            gateway = lib.mkOption {
              example = "192.168.2.1";
              type = lib.types.str;
            };
            interface = lib.mkOption {
              example = "enp4s0";
              type = lib.types.str;
            };
          };
        }
      );
    };
    local = lib.mkOption {
      default = { };
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            id = lib.mkOption {
              example = 1;
              type = lib.types.int;
            };
            cidr.v4 = lib.mkOption {
              example = "192.168.2.1";
              type = lib.types.str;
            };
            cidr.v6 = lib.mkOption {
              example = "fd14:d122:ca4c::";
              default = null;
              type = lib.types.nullOr lib.types.str;
            };
            interface = lib.mkOption {
              example = "enp4s0";
              type = lib.types.str;
            };
            trusted = lib.mkOption {
              type = lib.types.bool;
              default = false;
              description = ''
                Whether the network should be trusted.
                Trusted networks can access all ports and hosts on the local network regardless of the firewall rules
              '';
            };
            dhcp.v4 = lib.mkOption {
              type = lib.types.bool;
              default = true;
              description = ''
                Whether to run a DHCPv4 server on the network
              '';
            };
            dhcp.v6 = lib.mkOption {
              type = lib.types.bool;
              default = cfg.cidr.ipv6;
              description = ''
                Whether to run a DHCPv6 server on the network
              '';
            };
            reservations = lib.mkOption {
              type = lib.types.attrs;
              default = { };
              example = lib.literalExpression ''
                {
                  optina = { MACAddress = "d4:3d:7e:4d:c4:7f"; Address = "10.40.33.20"; };
                  valaam = { MACAddress = "00:c0:08:9d:ba:42"; Address = "10.40.33.21"; };
                  atari = { MACAddress = "94:08:53:84:9b:9d"; Address = "10.40.33.22"; };
                  kodiak = { MACAddress = "ec:f4:bb:e7:4b:dc"; Address = "10.40.33.23"; };
                  valaam-wifi = { MACAddress = "3c:58:c2:f9:87:5b"; Address = "10.40.33.31"; };
                  printer = { MACAddress = "a4:5d:36:d6:22:d9"; Address = "10.40.33.50"; };
                }
              '';
            };
          };
        }
      );
    };
  };
}
