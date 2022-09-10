{ pkgs }: {
  modules = import ./modules/nixos;
  homeManagerModules = import ./modules/home-manager;

  # Scoped packages
  vimPlugins = import ./pkgs/vim-plugins { inherit pkgs; };
  wallpapers = import ./pkgs/wallpapers { inherit pkgs; };
  roundcubePlugins = import ./pkgs/roundcube-plugins { inherit pkgs; };
  # Import packages to top-level
} // (import ./pkgs/top-level { inherit pkgs; })
