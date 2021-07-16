{ pkgs, ... }:

let hashed_password = import ./password.nix;
in {
  users = {
    mutableUsers = false;
    users.misterio = {
      isNormalUser = true;
      extraGroups = [ "wheel" "docker" ];
      shell = pkgs.zsh;
      initialHashedPassword = "${hashed_password}";
    };
  };

  imports = [
    ../../imports/home-manager/nixos
  ];

  security.pam.services.swaylock = {};
  systemd.services."autovt@tty1" = {
    description = "Autologin at the TTY1";
    after = [ "systemd-logind.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = [
      ""  # override upstream default with an empty ExecStart
      "@${pkgs.utillinux}/sbin/agetty agetty --login-program ${pkgs.shadow}/bin/login --autologin misterio --noclear %I $TERM"
    ];
    Restart = "always";
    Type = "idle";
    };
  };
  home-manager.useUserPackages = true;
  home-manager.users.misterio = {
    imports = [
      ../../imports/impermanence/home-manager.nix
      ./../../modules/colorscheme.nix
      ./../../modules/wallpaper.nix
      ./../../modules/ethminer.nix
      ./modules/alacritty.nix
      ./modules/direnv.nix
      ./modules/fzf.nix
      ./modules/git.nix
      ./modules/gpg-agent.nix
      ./modules/gtk.nix
      ./modules/rgbdaemon.nix
      ./modules/neofetch.nix
      ./modules/nvim.nix
      ./modules/pass.nix
      ./modules/qutebrowser.nix
      ./modules/starship.nix
      ./modules/sway.nix
      ./modules/waybar.nix
      ./modules/zathura.nix
      ./modules/zsh.nix
    ];

    wallpaper.generate = true;
    #wallpaper.path = "/dotfiles/assets/Wallpapers/astronaut-minimalism.png";
    colorscheme = import ./current-scheme.nix;

    services.ethminer = {
      enable = true;
      wallet = "0x16EeE21f85c06D3B983533b32Eef82d963d24f9a";
      pool = "eth-br.flexpool.io";
      port = 5555;
      rig = "misterio";
    };

    nixpkgs.config.allowUnfree = true;

    fonts.fontconfig.enable = true;

    home.packages = with pkgs; [
      (nerdfonts.override { fonts = [ "FiraCode" ]; })
      asciinema
      bottom
      cbonsai
      clinfo
      cmatrix
      discord
      dragon-drop
      ethminer-free
      fira
      fira-code
      glib
      gnome.zenity
      gsettings-desktop-schemas
      imv
      lm_sensors
      lutris
      openssl
      pinentry-gnome
      pipes
      spotify
      steam
      xdg-utils
    ];

    # Scripts
    home.file = { "bin".source = "/dotfiles/scripts"; };

    # Writable (persistent) data
    home.persistence."/data" = {
      directories = [
        "Documents"
        "Downloads"
        "Games"
        "Pictures"
        ".gnupg"
        ".local/share/password-store"
        ".local/share/Steam"
        ".local/share/lutris"
        ".config/lutris"
        ".local/share/Tabletop Simulator"
        ".config/Hero_Siege"
      ];
      allowOther = false;
    };
  };
}
