{
  system = {
    defaults = {
      trackpad = {
        Clicking = true;
        TrackpadThreeFingerDrag = true;
      };
      finder = {
        FXDefaultSearchScope = "SCcf";
        AppleShowAllExtensions = true;
        FXEnableExtensionChangeWarning = false;
        ShowStatusBar = true;
      };
      dock = {
    # Quick Note on the bottom right hot corner
        wvous-br-corner = 14;
        tilesize = 50;
      };
      NSGlobalDomain = {
        "com.apple.sound.beep.volume" = 0.000;
        InitialKeyRepeat = 13;
        KeyRepeat = 2;
      };
    };
      activationScripts.postUserActivation.text = ''
        # Following line should allow us to avoid a logout/login cycle
        /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
        launchctl stop com.apple.Dock.agent
        launchctl start com.apple.Dock.agent
        '';
    };
}
