{ stdenv, pkgs }:
stdenv.mkDerivation {
  name = "invoiceplane-template-notthebee";
  src = pkgs.fetchurl {
    url = "https://github.com/InvoicePlane/InvoicePlane/raw/refs/tags/v1.6.3/application/views/invoice_templates/pdf/InvoicePlane.php";
    hash = "sha256-x8xssyOtriKozCPG1JiJWXrFaf57Wyab9aZQn8WBreY=";
  };
  dontUnpack = true;
  buildOutputs = [ pkgs.gawk ];
  installPhase = ''
    mkdir -p $out
    awk '{
      print
      if ($0=="<div class=\"invoice-terms\">")
        print "<?php echo $custom_fields[\"client\"][\"Umsatzsteuer-Informationen\"] ?>"
    }' $src > $out/InvoicePlane_Custom.php
  '';
}
