{ pkgs, ... }: 
let
nixvim = inputs.nixvim.homeManagerModules.nixvim
in {
home.packages = with pkgs; [
  neovim
];

programs.neovim = {
  enable = true;
  viAlias = true;
  vimAlias = true;
  defaultEditor = true;
};
}
