{ pkgs, lib, ... }:
let
  lactConfig = {
    daemon = {
      log_level = "info";
      admin_groups = [
        "wheel"
        "sudo"
      ];
      disable_clocks_cleanup = false;
    };
    apply_settings_timer = 5;
    gpus = {
      "1002:744C-1EAE:7901-0000:07:00.0" = {
        fan_control_enabled = true;
        fan_control_settings = {
          mode = "curve";
          static_speed = 0.5;
          temperature_key = "edge";
          interval_ms = 500;
          curve = {
            "40" = 0.15406163;
            "50" = 0.30252102;
            "60" = 0.40056023;
            "70" = 0.50490195;
            "90" = 0.70308125;
          };
          spindown_delay_ms = 5000;
          change_threshold = 2;
        };
        power_cap = 300.0;
        performance_level = "auto";
      };
    };
  };
  settingsFormat = pkgs.formats.yaml { };
  lactConfigYaml = settingsFormat.generate "config.yaml" lactConfig;
in
{

  # Enable overclocking and fan control on AMD GPUs
  boot.kernelParams = [ "amdgpu.ppfeaturemask=0xffffffff" ];

  environment = {
    systemPackages = [ pkgs.lact ];
    etc = {
      "lact/config.yaml" = {
        source = lactConfigYaml;
        mode = "0644";
      };
    };
  };
  systemd = {
    packages = [ pkgs.lact ];
    services.lactd.wantedBy = [ "multi-user.target" ];
    services.lactd.preStart = ''
      ${lib.getExe pkgs.gnused} -i "s/'\([0-9]\{2\}\)':/\1:/" /etc/lact/config.yaml
    '';
  };

}
