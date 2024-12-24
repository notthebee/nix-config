{ pkgs, ... }:
{
  services.fail2ban = {
    enable = true;
  };
  environment.etc = {
    "fail2ban/action.d/cf.conf".text = pkgs.lib.mkDefault (
      pkgs.lib.mkAfter ''
        [Definition]

        actionstart =
        actionstop =
        actioncheck =

        actionban = /run/current-system/sw/bin/curl -s -o /dev/null -X POST \
              -H "X-Auth-Email: <cfuser>" \
              -H "X-Auth-Key: <cftoken>" \
              -H "Content-Type: application/json" \
              -d '{"mode":"block","configuration":{"target":"ip","value":"<ip>"},"notes":"Fail2Ban <name>"}' \
              "https://api.cloudflare.com/client/v4/user/firewall/access_rules/rules"

        actionunban = /run/current-system/sw/bin/curl -s -o /dev/null -X DELETE -H 'X-Auth-Email: <cfuser>' -H 'X-Auth-Key: <cftoken>' \
              https://api.cloudflare.com/client/v4/user/firewall/access_rules/rules/$(/run/current-system/sw/bin/curl -s -X GET -H 'X-Auth-Email: <cfuser>' -H 'X-Auth-Key: <cftoken>' \
              'https://api.cloudflare.com/client/v4/user/firewall/access_rules/rules?mode=block&configuration_target=ip&configuration_value=&page=1&per_page=1' | tr -d '\n' | cut -d'"' -f6)

        [Init]
        cftoken = your-token

        cfuser = jasper-at-windswept@example.com

      ''
    );
  };

}
