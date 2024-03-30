{ config, vars, pkgs, ... }:
let
directories = [
  "${vars.serviceConfigRoot}/iclouddrive"
  "${vars.serviceConfigRoot}/iclouddrive/session_data"
  "${vars.mainArray}/Media/iCloud"
];
settingsFormat = pkgs.formats.yaml { };
settingsFile = settingsFormat.generate "${vars.serviceConfigRoot}/iclouddrive/config.yaml" icloudDriveSettings;

icloudDriveSettings = {
  app = {
    logger = {
      level = "info";
      filename = "icloud.log";
    };
    credentials = {
      username = "ICLOUD_USERNAME";
      retry_login_interval = 600;
    };
    root = "icloud";
    smtp = {
      username = "${config.email.smtpUsername}";
      email = "${config.email.fromAddress}";
      to = "${config.email.toAddress}";
      host = "${config.email.smtpServer}";
      password = "SMTP_PASSWORD";
      port = 587;
      no_tls = false; 
    };
    region = "global";
  };
  drive = {
    destination = "drive";
    remove_obsolete = false;
    sync_interval = 86400;
    ignore = [
      "node_modules"
        "*.md"
    ];
  };
  photos = {
    destination = "photos"; 
    remove_obsolete = false;
    sync_interval = 86400;
    all_albums = true;
    folder_format = "%Y/%m";
  };
};

in
{
  system.activationScripts.icloudDriveConfigure = ''
    cp ${settingsFile} ${vars.serviceConfigRoot}/iclouddrive/config.yaml
    sed=${pkgs.gnused}/bin/sed
    icloudUsername=$(cat "${config.age.secrets.icloudDriveUsername.path}")
    smtpPassword=$(cat "${config.email.smtpPasswordPath}")
    configFile=${vars.serviceConfigRoot}/iclouddrive/config.yaml
    $sed -i"" "s/ICLOUD_USERNAME/$icloudUsername/g" $configFile
    $sed -i"" "s@SMTP_PASSWORD@$smtpPassword@g" $configFile
    '';

  systemd.tmpfiles.rules = map (x: "d ${x} 0775 share share - -") directories;
  virtualisation.oci-containers = {
    containers = {
      iclouddrive = {
        image = "mandarons/icloud-drive:latest";
        autoStart = true;
        volumes = [
          "${vars.mainArray}/Media/iCloud:/app/icloud"
            "${vars.serviceConfigRoot}/iclouddrive/config.yaml:/app/config.yaml"
            "${vars.serviceConfigRoot}/iclouddrive/session_data:/app/session_data"
        ];
        environment = {
          TZ = vars.timeZone;
          PUID = "994";
          GUID = "993";
        };
        environmentFiles = [
          config.age.secrets.icloudDrive.path
        ];
      };
    };
  };
}
