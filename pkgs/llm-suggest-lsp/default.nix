{
  lib,
  python3,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation {
  pname = "llm-suggest-lsp";
  version = "0.1.0";
  src = ./llm-suggest-lsp.py;
  dontUnpack = true;
  installPhase = ''
    runHook preInstall
    install -Dm755 $src $out/bin/llm-suggest-lsp
    substituteInPlace $out/bin/llm-suggest-lsp \
      --replace-fail '#!/usr/bin/env python3' '#!${lib.getExe python3}'
    runHook postInstall
  '';

  meta.mainProgram = "llm-suggest-lsp";
}
