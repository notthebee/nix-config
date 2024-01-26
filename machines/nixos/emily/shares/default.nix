{ users, pkgs, config, lib, ...}:
let

  smb = {
    share_list = {
      Backups = { path = "/mnt/user/Backups"; };
      Documents = { path = "/mnt/cache/Documents"; };
      Media = { path = "/mnt/user/Media"; };
      Misc = { path = "/mnt/user/Misc";  };
      TimeMachine = { path = "/mnt/cache/TimeMachine"; "fruit:time machine" = "yes"; };
      YoutubeArchive = { path = "/mnt/user/YoutubeArchive"; };
      YoutubeCurrent = { path = "/mnt/cache/YoutubeCurrent"; };
    };
    share_params = {
      "browseable" = "yes";
      "writeable" = "yes";
      "read only" = "no";
      "guest ok" = "no";
      "create mask" = "0644";
      "directory mask" = "0755";
      "valid users" = "share"; 
      "fruit:aapl" = "yes";
      "vfs objects" = "catia fruit streams_xattr";
    };
  };
  smb_shares = builtins.mapAttrs (name: value: value // smb.share_params) smb.share_list;
in
{
services.samba-wsdd.enable = true; # make shares visible for windows 10 clients

users = {
groups.share = {
  gid = 993;
};
users.share = {
  uid = 994;
  isSystemUser = true;
  group = "share";
};
};

environment.systemPackages = [ config.services.samba.package ];

users.users.notthebee.extraGroups = ["share"];

systemd.tmpfiles.rules = map (x: "d ${x.path} 0775 share share - -") (lib.attrValues smb.share_list) ++ ["d /mnt 0775 share share - -"];

system.activationScripts.samba_user_create = ''
    smb_password=$(cat "${config.age.secrets.sambaPassword.path}")
    echo -e "$smb_password\n$smb_password\n" | /run/current-system/sw/bin/smbpasswd -a -s share
    '';

networking.firewall = {
  allowedTCPPorts = [ 5357 ];
  allowedUDPPorts = [ 3702 ];
};

services.samba = {
  enable = true;
  openFirewall = true;
  invalidUsers = [
    "root"
  ];
  securityType = "user";
  extraConfig = ''
    workgroup = WORKGROUP
    server string = emily
    netbios name = emily
    security = user 
    hosts allow = 192.168.2.0/24 192.168.3.135/32 10.4.0.0/24
    guest account = nobody
    map to guest = bad user
    passdb backend = tdbsam
    '';
  shares = smb_shares;
};
services.avahi = {
  enable = true;
  nssmdns = true;
  publish = {
    enable = true;
    addresses = true;
    domain = true;
    hinfo = true;
    userServices = true;
    workstation = true;
  };
  extraServiceFiles = {
    smb = ''
      <?xml version="1.0" standalone='no'?><!--*-nxml-*-->
      <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
      <service-group>
      <name replace-wildcards="yes">%h</name>
      <service>
      <type>_smb._tcp</type>
      <port>445</port>
      </service>
      </service-group>
      '';
  };
};
}
