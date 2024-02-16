{ inputs, lib, config, pkgs, ... }:
{
  home.packages = with pkgs; [
    tmux
  ];
  programs.tmux = {
    enable = true;
    sensibleOnTop = false;
    extraConfig = ''
      set -g default-terminal "xterm-256color"
      set -ag terminal-overrides ",xterm-256color:RGB"
      set-option -g default-shell ${pkgs.zsh}/bin/zsh
      set -g status-keys vi


      set-window-option -g mode-keys vi
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      bind-key x kill-pane

      set -g set-titles-string ' #{pane_title} '

      bind-key / copy-mode \; send-key ?

      bind -n M-Left select-pane -L
      bind -n M-Right select-pane -R
      bind -n M-Up select-pane -U
      bind -n M-Down select-pane -D
      set -g mouse on
      set-option -g visual-activity off
      set-option -g visual-bell off
      set-option -g visual-silence off
      set-window-option -g monitor-activity off
      set-window-option -g mode-style bg=0,fg=default,noreverse
      set-window-option -g window-status-current-style bg=green,fg=black
      setw -g window-status-format " #I:#W#F "
      setw -g window-status-current-format " #I:#W#F "
      set-window-option -g window-status-style fg=green
      set-option -g renumber-windows on

      bind-key r source-file ~/.tmux.conf \; display-message "tmux.conf reloaded."


      # remap prefix from 'C-b' to 'C-s'
      unbind C-b
      set -g prefix C-s
      bind-key C-s send-prefix

      set-option -g bell-action none
      set -g status-position bottom
      set -g status-justify left
      set -g status-bg colour8
      set -g status-fg blue
      set -g status-right ' #(cd #{pane_current_path}; git rev-parse --abbrev-ref HEAD)    #{=50:pane_current_path}   %b %d %H:%M '
      set -g status-right-length 200
      set -g status-left '''
      set -sg escape-time 0

      set -g base-index 1
      setw -g pane-base-index 1
      set -g pane-border-format " #P: #{pane_current_command} "
      '';
    plugins = with pkgs.tmuxPlugins; [
      yank 
    ];
  };
}
