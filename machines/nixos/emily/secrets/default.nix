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
    invoiceNinja.file = "${inputs.secrets}/invoiceNinja.age";
    paperlessWebdav.file = "${inputs.secrets}/paperlessWebdav.age";
    paperlessPassword.file = "${inputs.secrets}/paperlessPassword.age";
    nextcloudCloudflared.file = "${inputs.secrets}/nextcloudCloudflared.age";
    nextcloudAdminPassword.file = "${inputs.secrets}/nextcloudAdminPassword.age";
    vaultwardenCloudflared.file = "${inputs.secrets}/vaultwardenCloudflared.age";
    microbinCloudflared.file = "${inputs.secrets}/microbinCloudflared.age";
    minifluxAdminPassword.file = "${inputs.secrets}/minifluxAdminPassword.age";
    minifluxCloudflared.file = "${inputs.secrets}/minifluxCloudflared.age";
    duckDNSDomain.file = "${inputs.secrets}/duckDNSDomain.age";
    duckDNSToken.file = "${inputs.secrets}/duckDNSToken.age";
    resticPassword = {
      file = "${inputs.secrets}/resticPassword.age";
      owner = "restic";
    };
  };
}
