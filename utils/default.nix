{ pkgs, ... }: {
  renderMustache = name: template: data:
    # Render handlebars `template` called `name` by converting `data` to JSON
    pkgs.stdenv.mkDerivation {

      name = "${name}";

      # Disable phases which are not needed. In particular the unpackPhase will
      # fail, if no src attribute is set
      nativeBuildInpts = [ pkgs.mustache-go ];

      # Pass Json as file to avoid escaping
      passAsFile = [ "jsonData" ];
      jsonData = builtins.toJSON data;

      phases = [ "buildPhase" "installPhase" ];

      buildPhase = ''
        ${pkgs.mustache-go}/bin/mustache $jsonDataPath ${template} > rendered_file
      '';
      installPhase = ''
        cp rendered_file $out
      '';
    };
}
