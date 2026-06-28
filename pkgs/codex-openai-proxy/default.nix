# Note: vibecoded (pi running claude-opus-4-8)
{
  lib,
  python3,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation {
  pname = "codex-openai-proxy";
  version = "0.1.0";
  src = ./codex-openai-proxy.py;
  dontUnpack = true;
  installPhase = ''
    runHook preInstall
    install -Dm755 $src $out/bin/codex-openai-proxy
    substituteInPlace $out/bin/codex-openai-proxy \
      --replace-fail '#!/usr/bin/env python3' '#!${lib.getExe python3}'
    runHook postInstall
  '';

  meta = {
    description = "OpenAI-compatible proxy for a ChatGPT Codex subscription";
    mainProgram = "codex-openai-proxy";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
}
