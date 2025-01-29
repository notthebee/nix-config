{
  config,
  pkgs,
  lib,
  ...
}:
let
  settingsFormat = pkgs.formats.yaml { };
  beet-wrapped = pkgs.writeScriptBin "beet-wrapped" ''
    sudo -u share BEETSDIR=/var/lib/slskd-import-files ${lib.getExe pkgs.beets} -c ${config.homelab.services.slskd.beetsConfigFile} "$@"
  '';
  beetsConfig = {
    directory = "${config.homelab.services.slskd.musicDir}";
    library = "${config.homelab.services.slskd.musicDir}/beets.db";

    plugins = [
      "fetchart"
      "lyrics"
      "lastgenre"
      "embedart"
      "duplicates"
    ];

    terminal_encoding = "utf-8";

    threaded = true;

    ui = {
      color = true;
    };

    import = {
      write = true;
      copy = true;
      move = false;
      autotag = true;
      bell = true;
      log = "/dev/null";
      quiet = true;
      quiet_fallback = "asis";
    };

    original_date = true;
    per_disc_numbering = true;

    embedart = {
      auto = true;
    };

    paths = {
      default = "$albumartist/($year) $album %aunique{}/$track $title %aunique{}";
      singleton = "$albumartist/($year) $album %aunique{}/$track $title %aunique{}";
      comp = "Compilations/$album %aunique{}/$track $title %aunique{}";
    };

    aunique = {
      keys = [
        "albumartist"
        "album"
      ];
      disambiguators = [
        "albumtype"
        "year"
        "label"
        "catalognum"
        "albumdisambig"
        "releasegroupdisambig"
      ];
      bracket = "[]";
    };

    fetchart = {
      auto = true;
      sources = [
        "filesystem"
        "coverart"
        "itunes"
        "amazon"
        "albumart"
        "fanarttv"
      ];
    };

    lastgenre = {
      auto = true;
      source = "album";
    };
  };
in
{
  config = {
    homelab.services.slskd.beetsConfigFile = settingsFormat.generate "beets.yaml" beetsConfig;
    environment.systemPackages = [ beet-wrapped ];
  };
}
