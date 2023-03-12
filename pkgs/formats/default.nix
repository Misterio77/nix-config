{ pkgs }:
{
  gzipJson = {}: {
    generate = name: value: pkgs.callPackage
      ({ runCommand, gzip }: runCommand name
        {
          nativeBuildInputs = [ gzip ];
          value = builtins.toJSON value;
          passAsFile = [ "value" ];
        } ''
        gzip "$valuePath" -c > "$out"
      '')
      { };

    type = (pkgs.formats.json { }).type;
  };
}
