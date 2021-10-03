{ pkgs, config, hostname, inputs, ... }:

let
  colorschemeFromPicture = picture: kind: import (pkgs.stdenv.mkDerivation {
    name = "generated-colorscheme";
    buildInputs = with pkgs; [ flavours ];
    unpackPhase = "true";
    buildPhase = ''
      template=$(cat <<-END
      {
        slug = "$(basename ${picture})-${kind}";
        name = "Generated";
        author = "{{scheme-author}}";
        colors = {
          base00 = "{{base00-hex}}";
          base01 = "{{base01-hex}}";
          base02 = "{{base02-hex}}";
          base03 = "{{base03-hex}}";
          base04 = "{{base04-hex}}";
          base05 = "{{base05-hex}}";
          base06 = "{{base06-hex}}";
          base07 = "{{base07-hex}}";
          base08 = "{{base08-hex}}";
          base09 = "{{base09-hex}}";
          base0A = "{{base0A-hex}}";
          base0B = "{{base0B-hex}}";
          base0C = "{{base0C-hex}}";
          base0D = "{{base0D-hex}}";
          base0E = "{{base0E-hex}}";
          base0F = "{{base0F-hex}}";
        };
      }
      END
      )

      flavours generate "${kind}" "${picture}" --stdout | \
      flavours build <( tee ) <( echo "$template" ) > default.nix
    '';
    installPhase = "mkdir -p $out && cp default.nix $out";
  });
in {
  imports = [
    inputs.impermanence.nixosModules.home-manager.impermanence
    inputs.nix-colors.homeManagerModule
    ./direnv.nix
    ./fish.nix
    ./git.nix
    ./neofetch.nix
    ./nix-index.nix
    ./nvim.nix
    ./starship.nix
  ] ++ (if hostname == "atlas" then [
    ./discord.nix
    ./element.nix
    ./ethminer.nix
    ./fira.nix
    ./gpg.nix
    ./gtk.nix
    ./kdeconnect.nix
    ./kitty.nix
    ./lutris.nix
    ./mail.nix
    ./mako.nix
    ./multimc.nix
    ./neomutt.nix
    ./osu.nix
    ./pass.nix
    ./qt.nix
    ./qutebrowser.nix
    ./rgbdaemon.nix
    # ./runescape.nix
    ./slack.nix
    ./steam.nix
    ./sway.nix
    ./swayidle.nix
    ./swaylock.nix
    ./waybar.nix
    ./zathura.nix
  ] else [ ]);

  nixpkgs = {
    config.allowUnfree = true;
    overlays = [ inputs.nur.overlay ];
  };

  programs.home-manager.enable = true;

  wallpaper.path = ../../wallpapers/river-snow-forest-painting.png;
  colorscheme = colorschemeFromPicture config.wallpaper.path "dark";

  systemd.user.startServices = "sd-switch";

  home.file.bin.source = ./scripts;

  home.packages = with pkgs; [
    # Cli
    bottom
    cachix
    exa
    ncdu
    ranger
    comma
  ] ++ (if hostname == "atlas" then [
    # Gui apps
    dragon-drop
    ydotool
    xdg-utils
    setscheme
    imv
    pavucontrol
    spotify
    wofi
  ] else [ ]);

  home.persistence = {
    "/data/home/misterio" = {
      directories = [ "Documents" "Downloads" "Pictures" ];
      allowOther = true;
    };
  };

}
