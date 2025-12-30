{pkgs, ...}: {
  home.packages = [pkgs.zoxide];
  programs.fish = {
    plugins = [{
      name = "zoxide";
      src = pkgs.fetchFromGitHub {
        owner = "icezyclon";
        repo = "zoxide.fish";
        rev = "27a058a661e2eba021b90e9248517b6c47a22674";
        hash = "sha256-OjrX0d8VjDMxiI5JlJPyu/scTs/fS/f5ehVyhAA/KDM=";
      };
    }];
  };
}

