{
  lib,
  pkgs,
  config,
  ...
}:
let
  networks = config.homelab.networks.local;

  adblockLocalZones = pkgs.stdenv.mkDerivation {
    name = "adblock";
    src = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/StevenBlack/hosts/refs/tags/3.16.19/hosts";
      sha256 = "fEDzjBHBOKME7cGxPVOxZoDKzCgKMFasCwNjnP+lyII=";
    };
    dontUnpack = true;
    buildPhase = ''
      cat $src | ${pkgs.gawk}/bin/awk '{sub(/\r$/,"")} {sub(/^127\.0\.0\.1/,"0.0.0.0")} BEGIN { OFS = "" } NF == 2 && $1 == "0.0.0.0" { print "local-zone: \"", $2, "\" refuse"}'  | tr '[:upper:]' '[:lower:]' | sort -u > zones
    '';
    installPhase = ''
      mv zones $out
    '';

  };

  internalIPs = (
    lib.lists.remove null (
      lib.lists.flatten (
        lib.mapAttrsToList (_: val: [
          val.cidr.v4
          val.cidr.v6
        ]) networks
      )
    )
  );
in
{
  services.unbound = {
    enable = true;
    settings = {
      server = {
        interface = internalIPs ++ [
          "127.0.0.1"
          "::1"
        ];
        port = "53";
        do-ip4 = true;
        do-udp = true;
        do-tcp = true;
        do-ip6 = true;
        prefer-ip6 = true;
        use-caps-for-id = false;
        edns-buffer-size = 1232;
        prefetch = true;
        num-threads = 1;
        so-rcvbuf = "1m";
        module-config = "\"dns64 validator iterator\"";
        dns64-prefix = config.networking.jool.nat64.default.global.pool6;
        include = toString adblockLocalZones;
        qname-minimisation = true;
        access-control = [
          "0.0.0.0/0 allow"
          "::/0 allow"
        ];
      };
    };
  };
}
