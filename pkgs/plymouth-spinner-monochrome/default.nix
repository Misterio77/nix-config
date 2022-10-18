{ stdenv, logo ? null, lib, ... }: stdenv.mkDerivation {
  pname = "plymouth-spinner-monochrome";
  version = "1.0";
  src = ./src;

  buildPhase = lib.optionalString (logo != null) ''
    cp $src . -r
    ln -s ${logo} ./share/plymouth/themes/spinner-monochrome/watermark.png
  '';

  installPhase = ''
    cp -r . $out
  '';

  meta = {
    platforms = lib.platforms.all;
  };
}
