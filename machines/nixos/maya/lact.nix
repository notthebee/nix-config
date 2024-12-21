{ pkgs, ... }:
let
  lactConfig = pkgs.writeTextFile {
    name = "config.yaml";
    text = builtins.readFile ./lact/config.yaml;
  };
in
{

  # Enable overclocking and fan control on AMD GPUs
  boot.kernelParams = [ "amdgpu.ppfeaturemask=0xffffffff" ];

  environment = {
    systemPackages = [ pkgs.lact ];
    etc = {
      "lact/config.yaml" = {
        source = lactConfig;
        mode = "0644";
      };
    };
  };
  systemd = {
    packages = [ pkgs.lact ];
    services.lactd.wantedBy = [ "multi-user.target" ];
  };

}
