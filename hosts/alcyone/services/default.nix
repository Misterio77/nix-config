{
  imports = [
    ../../common/optional/nginx.nix

    ./firefly.nix
    ./firefly-bot.nix
    ./files-server.nix
    ./git-remote.nix
    ./headscale.nix
    ./mail.nix
    ./radicale.nix

    ./cgit
    ./prometheus
    ./website
  ];
}
