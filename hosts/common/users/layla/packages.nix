{ pkgs, ... }:
{
  users.users.layla.packages = with pkgs; [
    steam
  ];
}
