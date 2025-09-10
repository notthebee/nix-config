{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.services.deemix;
  nodejs = pkgs.nodejs_20;
  pname = "deemix";
  version = "v4.3.0";
  src = pkgs.fetchFromGitHub {
    owner = "bambanah";
    repo = "deemix";
    rev = "05c66311a5e91a42471685217bc8efa2cb178860";
    hash = "sha256-OIMOupciEoj3CAblEAxfX5awjKySYPtvLfnzrUcIjzY=";
  };
  deemix = pkgs.stdenv.mkDerivation (finalAttrs: {
    inherit pname version src;

    nativeBuildInputs = [
      nodejs
      pkgs.pnpm.configHook
      pkgs.cacert
      pkgs.turbo
    ];

    pnpmDeps = pkgs.pnpm.fetchDeps {
      inherit (finalAttrs)
        pname
        version
        src
        ;
      hash = "sha256-7CEBFv85SngWekWhbKQhRRL7P/Llf6fQ3JSyu5+2SDc=";
    };

    buildPhase = ''
      runHook preBuild
      turbo prune deemix-webui --docker
      mkdir builder
      cp -r out/json/* builder
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      pushd builder
      pnpm install --frozen-lockfile
      cp -r ../out/full/* .
      pnpm turbo build --filter=deemix-webui...
      popd
      runHook postInstall
    '';

    postInstall = ''
      mkdir -p $out/bin
      rm -r $(find -type d -name .turbo)
      cp -r builder/* $out/
      cat <<EOF > $out/bin/deemix
      #!${pkgs.runtimeShell}
      exec ${nodejs}/bin/node $out/webui/dist/main.js
      EOF
      chmod +x $out/bin/deemix
    '';

  });
in
{
  options.services.deemix = {
    enable = lib.mkEnableOption "A web-based tool that facilitates downloading music from Deezer";
    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Open the port in the firewall for Deemix
      '';
    };
    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/deemix";
      description = ''
        The directory where Deemix stores its data files
      '';
    };
    musicDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/deemix/downloads";
      description = ''
        The directory for Deemix downloads
      '';
    };
    user = lib.mkOption {
      type = lib.types.str;
      default = "deemix";
      description = ''
        User account under which Deemix runs.
      '';
    };
    group = lib.mkOption {
      type = lib.types.str;
      default = "deemix";
      description = ''
        Group under which Deemix runs.
      '';
    };
    listenPort = lib.mkOption {
      type = lib.types.port;
      default = 6595;
      description = ''
        Port under which Deemix runs.
      '';
    };
    listenHost = lib.mkOption {
      type = lib.types.str;
      default = "0.0.0.0";
      description = ''
        Host which Deemix uses to run. Change to 127.0.0.1 if using a reverse proxy
      '';
    };
  };
  config = lib.mkIf cfg.enable {
    systemd.tmpfiles.settings."10-deemix".${cfg.dataDir}.d = {
      inherit (cfg) user group;
      mode = "0700";
    };

    systemd.services.deemix = {
      description = "Deemix is a web-based tool that facilitates downloading music from Deezer";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      environment = {
        DEEMIX_DATA_DIR = cfg.dataDir;
        DEEMIX_MUSIC_DIR = cfg.musicDir;
        DEEMIX_SERVER_PORT = toString cfg.listenPort;
        DEEMIX_SERVER_HOST = cfg.listenHost;
        NODE_ENV = "production";
      };
      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        ExecStart = "${deemix}/bin/deemix";
        Restart = "on-failure";
        StateDirectory = "deemix";
        PrivateTmp = true;
      };
    };

    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.listenPort ];
    };

    users.users = lib.mkIf (cfg.user == "deemix") {
      deemix = {
        group = cfg.group;
        home = cfg.dataDir;
        uid = config.ids.uids.deemix;
      };
    };

    users.groups = lib.mkIf (cfg.group == "deemix") {
      deemix = {
        gid = config.ids.gids.deemix;
      };
    };
  };
}
