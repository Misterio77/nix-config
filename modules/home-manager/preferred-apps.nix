{ lib, ... }:
let inherit (lib) types mkOption;
in
{
  options.home.preferredApps = mkOption {
    type = types.attrsOf (types.attrsOf (types.either types.str (types.functionTo types.str)));
    default = { };
  };
}

