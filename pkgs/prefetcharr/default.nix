{lib, rustPlatform, fetchFromGitHub, ...}:

rustPlatform.buildRustPackage {
  pname = "prefetcharr";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "p-hueber";
    repo = "prefetcharr";
    rev = "e08d67b74068b598abb982c7e866d5dcb111c6eb";
    hash = "sha256-REaszh+nKkw2BbL/V52Hnbic00rvj9UcwNotlVIUMWE=";
  };

  cargoHash = "sha256-b0dOd7xA3/dyRCetDtBmrWwdL/kVzV0KyzlxS8rA2Ck=";

  doCheck = false;
}
