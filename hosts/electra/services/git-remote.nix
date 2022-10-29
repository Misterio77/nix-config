{ config, lib, pkgs, ... }:
{

  environment.persistence = {
    "/persist".directories = [
      "/srv/git"
    ];
  };

  services.gitDaemon = {
    enable = true;
    basePath = "/srv/git";
    exportAll = true;
  };
  networking.firewall.allowedTCPPorts = [ 9418 ];

  users = {
    users.git = {
      home = "/srv/git";
      createHome = true;
      homeMode = "755";
      isSystemUser = true;
      shell = "${pkgs.bash}/bin/bash";
      group = "git";
      packages = [ pkgs.git ];
      openssh.authorizedKeys.keys =
        config.users.users.misterio.openssh.authorizedKeys.keys
        # Orgzly key
        ++ [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCXwKNjrj044YP4A0zftlXoZJLToEjUY3iQhmK5BvmzkpK+skFiW6SVLYXJOgzh6TarwWztySUbT9uFo4cEsSR1jiiT9KwWQmrzjfKGsbTL18yltqa5P68+HEk/I89oiyYQpSdTKT4SniIG8lg13AbfJOUdfqWg5RCNZRGWCknDorExa6vocWUSpmcJzPz/7GcW0jRYH7eAqJXaxiMvs7bEILCxiKoBHkRf99rpPpgWell4Py93puZfn0N5f+S8IFamr5UGfXm03Gg9/yOWW/CGFNv2k/R2LxtDVbqdbotGkxVUQLzH8HEjQc2rUSP0LmRoeUULd+NGSTJowLKi3Emyr3VLf3XFtSkJnQLB/plGYbPbbQ0E3MohskeYiFwa4mZlARWHLtSDLjIbei7xYJZzotO0aTMOMRe+OLRJnc75USHn94P8gJ25XHiuO607a5CdN0qhbIvaPRpoSatlhekIXfkAR1f8n+NRMds8J05Cr1TOx/f7DCdXaxFKHhClcSrYKUK3ghOGnZVqkzYrrTx9hSO+kEmTNKSeU5tDAy0fY3fxty13+WkfUEZFXA2j2myRCiOf4cQ+FSbG0DwlQJSK++x0Y9nrpX689NyrVKo3ukPDOEHgxF+JbD7aqCCc7GQZj1S18gVOxF7FaZ8GbfP0SxSaeyRZoqApZWubMNoTWQ==" ];
    };
    groups.git = { };
  };
}
