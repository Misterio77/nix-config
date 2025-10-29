{lib, pkgs, ...}: {
  imports = [
    ../common/optional/keyd.nix
  ];

  services.keyd = {
    keyboards = {
      remoteControl = {
        ids = [
          "1915:1025"
        ];
        settings.main = {
          # Back button
          # Go back (e.g. firefox and steam)
          rightmouse = "mouse1";
          # Mic button
          # Mute sound
          voicecommand = "mute";
        };
      };
    };
  };

  powerManagement.resumeCommands = ''
    ${pkgs.kmod}/bin/rmmod xhci_pci
    sleep 1
    ${pkgs.kmod}/bin/modprobe xhci_pci
  '';
}
