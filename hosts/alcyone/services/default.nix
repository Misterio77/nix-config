{
  imports = [
    ../../common/optional/nginx.nix

    ./firefly.nix
    ./firefly-bot.nix
    ./files-server.nix
    ./git-remote.nix
    ./headscale.nix
    ./mail.nix
    ./prometheus.nix
    ./radicale.nix

    ./cgit
    ./website
  ];
}
