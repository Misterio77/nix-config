{ inputs, pkgs, ... }:
let
  inherit (inputs.nix-minecraft.packages.${pkgs.system}) minecraftServers;
in
{
  imports = [ inputs.nix-minecraft.nixosModules.minecraft-servers ];

  services.minecraft-servers = {
    enable = true;
    eula = true;
    servers = {
      vanilla = {
        enable = true;
        package = minecraftServers.vanilla; # Latest vanilla
        serverProperties = {
          motd = "Vanilla";
        };
      };
    };
  };
}
