{pkgs ? import <nixpkgs> {}, ...}: rec {
  # Packages with an actual source
  lyrics = pkgs.python3Packages.callPackage ./lyrics {};
  prefetcharr = pkgs.callPackage ./prefetcharr {};
  hyprbars = pkgs.callPackage ./hyprbars {};
  jellysearch = pkgs.callPackage ./jellysearch {};

  # Personal scripts
  minicava = pkgs.callPackage ./minicava {};
  pass-wofi = pkgs.callPackage ./pass-wofi {};
  xpo = pkgs.callPackage ./xpo {};
  clip-notify = pkgs.callPackage ./clip-notify {};

  # My slightly customized plymouth theme, just makes the blue outline white
  plymouth-spinner-monochrome = pkgs.callPackage ./plymouth-spinner-monochrome {};
}
