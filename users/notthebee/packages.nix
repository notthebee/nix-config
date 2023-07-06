{ pkgs, ...}: {
  home.packages = with pkgs; [
      ansible-lint
      ansible 
      (python39.withPackages(ps: with ps; [ 
                            setuptools
                            pip 
                            pre-commit
      ]))
  ];
}
