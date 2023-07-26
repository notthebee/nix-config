{ homeDir }:
{
  eslint.autoFixOnSave = true;
  coc.preferences.colorSupport = false;
  prettier.disableSuccessMessage = true;
  coc.preferences.formatOnSaveFiletypes = [
    "css"
    "javascript"
    "javascriptreact"
    "typescript"
    "typescriptreact"
    #"ansible"
  ];
  suggest.completionItemKindLabels = {
    variable = "";
    constant = "";
    struct = "פּ";
    class = "ﴯ";
    interface = "";
    text = "";
    enum = "";
    enumMember = "";
    color = "";
    property = "ﰠ";
    field = "ﰠ";
    unit = "塞";
    file = "";
    value = "";
    event = "";
    folder = "";
    keyword = "";
    snippet = "";
    operator = "";
    reference = "";
    typeParameter = "";
    default = "";
  };
  suggest.noselect = false;
  diagnostic.warningSign = "";
  diagnostic.errorSign = "";
  diagnostic.infoSign = "";
  python.jediEnabled = false;
  languageserver = {
    nix = {
      command = "rnix-lsp";
      filetypes = ["nix"];
    };
  };
  ansible.dev.serverPath = "${homeDir}/.nix-profile/bin/ansible-language-server";
  ansible.builtin.isWithYamllint = true;
  ansible.disableProgressNotification = false;
  explorer.icon.enableNerdfont = true;
  explorer.width = 30;
  explorer.file.showHiddenFiles = true;
  explorer.openAction.strategy = "sourceWindow";
  explorer.root.customRules = {
    vcs = {
      patterns = [ ".git" ".hg" ".projections.json" ];
    };
    vcs-r = {
      patterns = [ ".git" ".hg" ".projections.json" ];
      bottomUp = true;
    };
  };
  explorer.root.strategies = [ "custom:vcs" "workspace" "cwd" ];
  explorer.quitOnOpen = true;
  explorer.buffer.root.template = "[icon & 1] OPEN EDITORS";
  explorer.file.reveal.auto = false;
  explorer.file.root.template = "[icon & 1] PROJECT ([root])";
  explorer.file.child.template = "[git | 2] [selection | clip | 1] [indent][icon | 1] [diagnosticError & 1][filename omitCenter 1][modified][readonly] [linkIcon & 1][link growRight 1 omitCenter 5]";
  explorer.keyMappings = {
    s = "open:vsplit";
    mm = "rename";
    mc = "copyFile";
    C = "copyFile";
    md = "delete";
    D = "delete";
    ma = "addFile";
    mA = "addDirectory";
  };
}
