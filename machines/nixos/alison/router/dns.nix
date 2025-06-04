{ ... }:
{
  services = {
    https-dns-proxy = {
      enable = true;
      port = 10053;
    };
    dnsmasq = {
      enable = true;
      settings = {
        cache-size = 10000;
        bind-dynamic = true;

        # Needed to force dnsmasq to only use the servers specified in this config file
        no-resolv = true;
        conf-file = false;
        resolv-file = false;

        except-interface = [
          "podman0"
          "wan0"
        ];
        server = [ "127.0.0.1#10053" ];
      };
    };
  };
}
