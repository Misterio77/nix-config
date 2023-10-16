{ pkgs, lib, ... }:
let
  # Add PULSE_LATENCY_MSEC to .desktop file
  pulse_latency = 100;
  runescape = pkgs.runescape.overrideAttrs (oa: {
    nativeBuildInputs = (oa.nativeBuildInputs or []) ++ [
      pkgs.makeWrapper
    ];
    buildCommand = (oa.buildCommand or "") + /* bash */ ''
      wrapProgram "$out/bin/RuneScape" \
        --set PULSE_LATENCY_MSEC ${toString pulse_latency} \
        --run 'echo $PULSE_LATENCY_MSEC'
    '';
  });
  openssl = lib.head (lib.filter (p: p.pname == "openssl") runescape.fhsenv.targetPaths);
in {
  home.packages = [
    runescape
    pkgs.hdos
    pkgs.runelite
  ];

  nixpkgs.config.permittedInsecurePackages = [
    openssl.name
  ];

  home.persistence = {
    "/persist/home/misterio" = {
      allowOther = true;
      directories = [
        "Jagex"
      ];
    };
  };
}
