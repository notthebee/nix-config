{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.homelab.services.delugevpn;
  homelab = config.homelab;
in
{
  options.homelab.services.delugevpn = {
    enable = lib.mkEnableOption "Deluge torrent client (bound to a Wireguard VPN network)";
    configDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/deluge";
    };
    url = lib.mkOption {
      type = lib.types.str;
      default = "deluge.${homelab.baseDomain}";
    };
    homepage.name = lib.mkOption {
      type = lib.types.str;
      default = "Deluge";
    };
    homepage.description = lib.mkOption {
      type = lib.types.str;
      default = "Torrent client";
    };
    homepage.icon = lib.mkOption {
      type = lib.types.str;
      default = "deluge.svg";
    };
    homepage.category = lib.mkOption {
      type = lib.types.str;
      default = "Downloads";
    };
    wireguard.configFile = lib.mkOption {
      type = lib.types.path;
      description = "Path to a file with Wireguard config";
      example = lib.literalExpression ''
        pkgs.writeText "wg0.conf" '''
          [Interface]
          Address = 192.168.2.2
          PrivateKey = <client's privatekey>
          ListenPort = 21841

          [Peer]
          PublicKey = <server's publickey>
          Endpoint = <server's ip>:51820
        '''
      '';
    };
    wireguard.privateIP = lib.mkOption {
      type = lib.types.str;
    };
    wireguard.dnsIP = lib.mkOption {
      type = lib.types.str;
    };
  };
  config = lib.mkIf cfg.enable {
    services.deluge = {
      enable = true;
      user = homelab.user;
      group = homelab.group;
      web = {
        enable = true;
      };
    };

    services.caddy.virtualHosts."${cfg.url}" = {
      useACMEHost = homelab.baseDomain;
      extraConfig = ''
        reverse_proxy http://127.0.0.1:8112
      '';
    };

    systemd.services."netns@" = {
      description = "%I network namespace";
      before = [ "network.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${pkgs.iproute2}/bin/ip netns add %I";
        ExecStop = "${pkgs.iproute2}/bin/ip netns del %I";
      };
    };
    environment.etc."netns/deluge/resolv.conf".text = "nameserver ${cfg.wireguard.dnsIP}";

    systemd.services.deluged.bindsTo = [ "netns@deluge.service" ];
    systemd.services.deluged.requires = [
      "network-online.target"
      "wg-deluge.service"
    ];
    systemd.services.deluged.serviceConfig.NetworkNamespacePath = [ "/var/run/netns/deluge" ];

    # allowing delugeweb to access deluged in network namespace, a socket is necesarry
    systemd.sockets."deluged-proxy" = {
      enable = true;
      description = "Socket for Proxy to Deluge WebUI";
      listenStreams = [ "58846" ];
      wantedBy = [ "sockets.target" ];
    };

    systemd.services."deluged-proxy" = {
      enable = true;
      description = "Proxy to Deluge Daemon in Network Namespace";
      requires = [
        "deluged.service"
        "deluged-proxy.socket"
      ];
      after = [
        "deluged.service"
        "deluged-proxy.socket"
      ];
      unitConfig = {
        JoinsNamespaceOf = "deluged.service";
      };
      serviceConfig = {
        User = config.services.deluge.user;
        Group = config.services.deluge.group;
        ExecStart = "${pkgs.systemd}/lib/systemd/systemd-socket-proxyd --exit-idle-time=5min 127.0.0.1:58846";
        PrivateNetwork = "yes";
      };
    };

    systemd.services.wg-deluge = {
      description = "wg network interface (Deluge)";
      bindsTo = [ "netns@deluge.service" ];
      requires = [ "network-online.target" ];
      after = [ "netns@deluge.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart =
          with pkgs;
          writers.writeBash "wg-up" ''
            see -e
            ${iproute2}/bin/ip link add wg0 type wireguard
            ${iproute2}/bin/ip link set wg0 netns deluge
            ${iproute2}/bin/ip -n deluge address add ${cfg.wireguard.privateIP} dev wg0
            ${iproute2}/bin/ip netns exec deluge \
            ${pkgs.wireguard-tools}/bin/wg setconf wg0 ${cfg.wireguard.configFile}
            ${iproute2}/bin/ip -n deluge link set wg0 up
            ${iproute2}/bin/ip -n deluge link set lo up
            ${iproute2}/bin/ip -n deluge route add default dev wg0
          '';
        ExecStop =
          with pkgs;
          writers.writeBash "wg-down" ''
            see -e
            ${iproute2}/bin/ip -n deluge route del default dev wg0
            ${iproute2}/bin/ip -n deluge link del wg0
          '';
      };
    };
  };
}
