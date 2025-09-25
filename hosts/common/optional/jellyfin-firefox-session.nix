{pkgs, lib, ...}: let
  firefox = pkgs.wrapFirefox pkgs.firefox-unwrapped {
    extraPolicies = {
      AutofillAddressEnabled = false;
      AutofillCreditCardEnabled = false;
      BlockAboutAddons = true;
      BlockAboutConfig = true;
      BlockAboutProfiles = true;
      BlockAboutSupport = true;
      CaptivePortal = false;
      DisableDeveloperTools = true;
      DisableFeedbackCommands = true;
      DisableFirefoxAccounts = true;
      DisableFirefoxScreenshots = true;
      DisableFirefoxStudies = true;
      DisableFormHistory = true;
      DisablePocket = true;
      DisableSetDesktopBackground = true;
      DisableTelemetry = true;
      DisplayBookmarksToolbar = "never";
      DisplayMenuBar = "never";
      DontCheckDefaultBrowser = true;
      InstallAddonsPermission.Default = false;
      NewTabPage = false;
      NoDefaultBookmarks = true;
      OfferToSaveLogins = false;
      OfferToSaveLoginsDefault = false;
      OverrideFirstRunPage = "";
      OverridePostUpdatePage =  "";
      PasswordManagerEnabled = false;
      Homepage = {
        URL = "https://media.m7.rs";
        Locked = true;
      };
      UserMessaging = {
        ExtensionRecommendations = false;
        SkipOnboarding = true;
      };
    };
  };
  sessionFile =
    (pkgs.writeTextDir "share/wayland-sessions/jellyfin-kiosk.desktop" ''
      [Desktop Entry]
      Name=Jellyfin
      Comment=A media platform
      Exec=${lib.getExe pkgs.cage} -s -m last -- ${lib.getExe firefox} https://media.m7.rs
      Type=Application
    '').overrideAttrs
      (_: {
        passthru.providedSessions = [ "jellyfin-kiosk" ];
      });
in {
  services.displayManager.sessionPackages = [sessionFile];
}
