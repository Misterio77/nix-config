{
  services.keyd = {
    enable = true;
    keyboards = {
      remoteControl = {
        ids = [
          "1915:1025"
        ];
        settings.main = {
          # Homepage button
          # Go to firefox homepage (alt+home)
          homepage = "A-home";
          # Back button
          # Go back (e.g. firefox and steam)
          rightmouse = "mouse1";
          # Menu button
          # Open quick settings on steam
          # TODO: do something cool in firefox/media kiosk
          compose = "C-2";
          # Mic button
          # Mute sound (yeah not very creative)
          voicecommand = "mute";
        };
      };
    };
  };
}
