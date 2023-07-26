{ inputs, pkgs, lib, ... }:
let
  ourPythonPackagesForAnsible = pkgs.python311Packages.override
    (oldAttrs: {
      overrides = pkgs.lib.composeManyExtensions [
        (oldAttrs.overrides or (_: _: { }))
        (pfinal: pprev: {
          ansible = pprev.ansible.overridePythonAttrs (old: {
            propagatedBuildInputs = (old.propagatedBuildInputs or [ ]) ++ [ pfinal.boto pfinal.boto3 pfinal.pyyaml ];
            makeWrapperArgs = (old.makeWrapperArgs or []) ++ [ "--prefix PYTHONPATH : $PYTHONPATH" ];
          });
        })
      ];
    });
  ourAnsible =
    (ourPythonPackagesForAnsible.toPythonApplication ourPythonPackagesForAnsible.ansible);
in
{

  imports = [ ./system.nix ];
  homebrew = {
    casks = [
      "google-chrome"
        "slack"
        "zoom"
        "mattermost"
        "viscosity"
        "sequel-ace"
    ];

    masApps = {
      "microsoft-outlook" = 985367838;
    };
  };

  environment.shellInit = ''
    ulimit -n 2048
    '';


  environment.systemPackages = with pkgs; [
      (python311.withPackages(ps: with ps; [ 
      pip 
      requests
      setuptools
      pyyaml
      ]))
      ansible-language-server
      yq
      git-lfs
      pre-commit
  ];

  }
