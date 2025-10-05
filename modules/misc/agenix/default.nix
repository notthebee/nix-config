{
  inputs,
  ...
}:
{
  age = {
    secrets = {
      sambaPassword.file = "${inputs.secrets}/sambaPassword.age";
      cloudflareDnsApiCredentials.file = "${inputs.secrets}/cloudflareDnsApiCredentials.age";
      tailscaleAuthKey.file = "${inputs.secrets}/tailscaleAuthKey.age";
      resticBackblazeEnv.file = "${inputs.secrets}/resticBackblazeEnv.age";
      tgNotifyCredentials.file = "${inputs.secrets}/tgNotifyCredentials.age";
      gitIncludes.file = "${inputs.secrets}/gitIncludes.age";
    };
  };
}
