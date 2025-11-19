{ inputs, ... }:
{
  age.secrets = {
    wireguardCredentials.file = "${inputs.secrets}/wireguardCredentials.age";
    borgBackupKey.file = "${inputs.secrets}/borgBackupKey.age";
    radicaleHtpasswd.file = "${inputs.secrets}/radicaleHtpasswd.age";
    cloudflareFirewallApiKey.file = "${inputs.secrets}/cloudflareFirewallApiKey.age";
    keycloakDbPasswordFile.file = "${inputs.secrets}/keycloakDbPasswordFile.age";
    keycloakCloudflared.file = "${inputs.secrets}/keycloakCloudflared.age";
    adiosBotToken.file = "${inputs.secrets}/adiosBotToken.age";
    borgBackupSSHKey.file = "${inputs.secrets}/borgBackupSSHKey.age";
    invoicePlaneDbPasswordFile.file = "${inputs.secrets}/invoicePlaneDbPasswordFile.age";
    paperlessWebdav.file = "${inputs.secrets}/paperlessWebdav.age";
    slskdEnvironmentFile = {
      file = "${inputs.secrets}/slskdEnvironmentFile.age";
      owner = "share";
    };
    paperlessPassword.file = "${inputs.secrets}/paperlessPassword.age";
    nextcloudCloudflared.file = "${inputs.secrets}/nextcloudCloudflared.age";
    navidromeCloudflared.file = "${inputs.secrets}/navidromeCloudflared.age";
    navidromeEnv.file = "${inputs.secrets}/navidromeEnv.age";
    nextcloudAdminPassword.file = "${inputs.secrets}/nextcloudAdminPassword.age";
    vaultwardenCloudflared.file = "${inputs.secrets}/vaultwardenCloudflared.age";
    microbinCloudflared.file = "${inputs.secrets}/microbinCloudflared.age";
    minifluxAdminPassword.file = "${inputs.secrets}/minifluxAdminPassword.age";
    minifluxCloudflared.file = "${inputs.secrets}/minifluxCloudflared.age";
    duckDNSDomain.file = "${inputs.secrets}/duckDNSDomain.age";
    duckDNSToken.file = "${inputs.secrets}/duckDNSToken.age";
    withings2intervals.file = "${inputs.secrets}/withings2intervals.age";
    withings2intervals_authcode.file = "${inputs.secrets}/withings2intervals_authcode.age";
    resticPassword = {
      file = "${inputs.secrets}/resticPassword.age";
      owner = "restic";
    };
  };
}
