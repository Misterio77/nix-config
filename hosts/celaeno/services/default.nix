{
  imports = [
    ../../common/optional/nginx.nix

    ./binary-cache.nix
    ./paste-misterio-me.nix
    ./sitespeedio.nix

    ./hydra
    ./minecraft
  ];
}
