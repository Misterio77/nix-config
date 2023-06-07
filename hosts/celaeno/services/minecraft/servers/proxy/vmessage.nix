{ pkgs, ... }: {
  services.minecraft-servers.servers.proxy = {
    extraReload = ''
      mcrun vmessage reload
    '';
    symlinks = {
      "plugins/Vmessage.jar" = pkgs.fetchurl rec {
        pname = "Vmessage";
        version = "1.5.4";
        url = "https://github.com/FeuSalamander/${pname}/releases/download/${version}/${pname}.jar";
        hash = "sha256-ie2yJjBwd/NShFSGp8WF3iPG1Z3bXYlmOubWCP8j/z4=";
      };
    };
    files = {
      "plugins/vmessage/config.toml".value = {
        Message-format.minimessage = false;
        Message = {
          enabled = false;
          commands = [];
        };
        Server-change = {
          enabled = false;
          commands = [];
        };
        Join = {
          enabled = true;
          format = "#prefix##player#&e entrou no servidor";
          commands = [];
        };
        Leave = {
          enabled = true;
          format = "#prefix##player#&e saiu do servidor";
          commands = [];
        };
      };
    };
  };
}
