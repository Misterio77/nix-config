{ inputs, lib, pkgs, config, outputs, ... }:
let
  inherit (inputs.nix-colors) colorSchemes;
  inherit (inputs.nix-colors.lib-contrib { inherit pkgs; }) colorschemeFromPicture nixWallpaperFromScheme;
in
{
  imports = [
    inputs.impermanence.nixosModules.home-manager.impermanence
    inputs.nix-colors.homeManagerModule
    ../features/cli
    ../features/nvim
  ] ++ (builtins.attrValues outputs.homeManagerModules);

  nixpkgs = {
    overlays = builtins.attrValues outputs.overlays;
    config = {
      allowUnfree = true;
      allowUnfreePredicate = (_: true);
    };
  };

  nix = {
    package = lib.mkDefault pkgs.nix;
    settings = {
      experimental-features = [ "nix-command" "flakes" "repl-flake" ];
      warn-dirty = false;
    };
  };

  systemd.user.startServices = "sd-switch";

  programs = {
    home-manager.enable = true;
    git.enable = true;
  };

  home = {
    username = lib.mkDefault "misterio";
    homeDirectory = lib.mkDefault "/home/${config.home.username}";
    stateVersion = lib.mkDefault "22.05";

    persistence = {
      "/persist/home/misterio" = {
        directories = [
          "Documents"
          "Downloads"
          "Pictures"
          "Videos"
        ];
        allowOther = true;
      };
    };
  };

  colorscheme = lib.mkDefault colorSchemes.dracula;
  wallpaper = lib.mkDefault (nixWallpaperFromScheme {
    scheme = config.colorscheme;
    width = 2560;
    height = 1080;
    logoScale = 4.5;
  });
  home.file.".colorscheme".text = config.colorscheme.slug;
}
