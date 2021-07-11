{ lib, config, ... }:

# TODO WIP
with lib;
{
  options.monitors = mkOption {
    type = types.listOf (types.submodule {
      options = {
        name = mkOption {
          type = types.str;
          example = "HDMI-A-1";
          description = "Monitor name";
        };
        resolution = {
          height = mkOption {
            type = types.int;
            default = 1080;
            example = literalExample "1080";
            description = "Monitor resolution height";
          };
          width = mkOption {
            type = types.int;
            default = 1920;
            example = literalExample "2560";
            description = "Monitor resolution height";
          };
          frequency = mkOption {
            type = types.int;
            default = 60;
            example = literalExample "60";
            description = "Monitor refresh rate, in Hz";
          };
        };
        position = {
          x = mkOption {
            type = types.int;
            default = 0;
            example = literalExample "1080";
            description = "Monitor x position";
          };
          y = mkOption {
            type = types.int;
            default = 0;
            example = literalExample "2560";
            description = "Monitor y position";
          };
        };
        assign = mkOption {
          type = types.listOf (types.str);
          default = [ ];
          example = literalExample ''[ "workspace number 1", "workspace number 3" ]'';
          description = "Workspace names to be assigned to this monitor";
        };
      };
    });
    default = [ ];
    description = "Monitors to be used";
  };
}
